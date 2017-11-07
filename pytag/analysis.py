#!/usr/bin/env python

# Built-in modules #
from xml.dom import minidom
import fileinput
import os, io

# Third party modules #
import bibtexparser

# Internal modules #
from pytag.annotation import annotate_abstract
from pytag.ontologies import extract_terms


##########################################################################################################
class Analysis(object):
    """The main object. The mandatory arguments are the input BibTex files path, the numerical identifiers
    for the ontologies to be used for annotation and the name of the output TSV file for the results to be
    written.

    * '--input_dir' : The BibTex/txt file/s to process in the specified directory.
    * '--onto_types' : The ontologies to be used for annotation. Can be one of the following identifiers:"
                             0 : Genes/Proteins
                            -1 : PubChem Compound identifiers
                            -2 : NCBI Taxonomy entries
                            -21 : Gene Ontology biological process terms
                            -22 : Gene Ontology cellular component terms
                            -23 : Gene Ontology molecular function terms
                            -25 : BRENDA Tissue Ontology terms
                            -26 : Disease Ontology terms
                            -27 : Environment Ontology terms
                            all : Select all types
    * '--out_file' : 'Output name for the TSV table with the annotated terms.'
    """

    def __init__(self, input_dir, onto_types, out_file):
        self.input_dir = input_dir
        self.onto_types = onto_types
        self.out_file = out_file

    def process(self):
        """A method to process the BibTex files. The abstract text for each reference is collected
        either from the BibTex file if available, or alternatively the relevant pubmed ID is extracted
        and the associated abstract is downloaded and annotated next. The results of the annotation
        process are described in the output files.
        """
        # Total number of Bibtex files #
        count_samples = 0
        # Total number of annotated abstracts (in all Bibtex files) #
        count_tot_annot_abstr = 0
        # Total number of references (in all Bibtex files) #
        count_papers = 0
        
        # Create the file where the annotated terms for each reference will be recorded #
        with open(self.out_file, "w") as tsv_file:
           # Create the file where the total number of references, available #
           # and annotated abstracts per BibTex file will be recorded #
           with open("annotation_summary.tsv", "w") as tsv_total_refer_file:
                tsv_total_refer_file.write("\tTotal_number_of_references\tAvailable_abstracts\tAnnotated_abstracts\n")  
                # Iterate over every BibTex file included in the specified directory #
                for infile in os.listdir(self.input_dir):
                      # Process files with TXT or BIB extension #
                      if (infile.endswith(".txt") or infile.endswith(".bib")):

                              # Increment by one for every file being processed #
                              count_samples = count_samples + 1
                              # Print the name of the file which is being processed #
                              print("Processing file:", count_samples, infile)
                              
                              # Count how many abstracts were annotated in one Bibtex file #
                              count_annot_abstr_psamp = 0
                              # Count how many references were described in one Bibtex file #
                              # (with or without abstract included) #
                              count_total_refer_psamp = 0
                              # Count how many references did not have an abstract for one Bibtex file #
                              count_noabstr_psamp = 0
                              # Count how many abstracts were available/obtained for one Bibtex file #
                              # (annotated or not) #
                              count_tot_abstr_psamp = 0

                              # Open the file in a reading mode and set the encoding #
                              with io.open(self.input_dir+infile, mode="r", encoding="cp1252") as bibtex_file:
                                      # Read the contents of the file and assign them in a string variable #
                                      bibtex_str = bibtex_file.read()
                                      # Load the data using the 'bibtextparser' module #
                                      bib_database = bibtexparser.loads(bibtex_str)

                                      # Iterate over each entry (reference) of the BibTex file #
                                      for el in bib_database.entries:
                                            # Increment by one for every reference found (used for all BibTex files) #
                                            count_papers += 1
                                            # Increment by one for every reference found in the file being processed #
                                            # (used separately for each BibTex file) #
                                            count_total_refer_psamp += 1
                                            # Assing the records of the reference in a string variable #
                                            records_refer = str(el)

                                            # Labels used to locate the required records #
                                            find_ac_num = "'accession number':"
                                            find_pmid = "'pubmed id':"
                                            find_abstract = "'abstract':"
                                            address = ''
                                            abstract = ''
                                            
                                            # Extract the pmid or accession number and form the associated link for PubMed database #
                                            if(find_ac_num in records_refer):
                                                  pmid = el["accession number"]
                                                  address = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id='+pmid+'&retmode=xml'
                                            elif(find_pmid in records_refer):
                                                  pmid = el["pubmed id"]
                                                  address = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id='+pmid+'&retmode=xml'

                                            if address:
                                                # If an abstract is already available in the BibTex file then use it #
                                                if(find_abstract in records_refer):
                                                    abstract = el["abstract"]

                                                # Annotate the abstract text #
                                                terms_table = annotate_abstract(address, abstract, self.onto_types)
                                                linetofile = extract_terms(terms_table, pmid, infile, tsv_file)
                                                
                                                # If the abstract text was annotated (i.e. at least one term was identified in its content) #
                                                if linetofile:
                                                      # Increment by one the total number of the annotated abstracts #
                                                      count_tot_annot_abstr += 1
                                                      # Increment by one the total number of the annotated #
                                                      # abstracts for the BibTex file being processed #
                                                      count_annot_abstr_psamp += 1
                                                      # Increment by one the total number of the abstracts #
                                                      # collected for the BibTex file being processed #
                                                      count_tot_abstr_psamp += 1
                                                # If no terms were identified in the abstract text, #
                                                # then print the pmid of the associated reference # 
                                                elif(not linetofile and abstract):
                                                      print("no annotation for reference with Pubmed ID: ", pmid)
                                                      # Increment by one the total number of the abstracts #
                                                      # collected for the BibTex file being processed #
                                                      count_tot_abstr_psamp += 1
                                                # If the abstract could not be collected for the reference being processed #
                                                elif(not linetofile and not abstract):
                                                      # Increment by one the total number of the abstracts #
                                                      # not collected for the BibTex file being processed #
                                                      count_noabstr_psamp += 1

                              # Update the TSV table for the annotation summary#
                              tot_num_of_refer_per_sample = str(infile.rsplit('.', 1)[0]+"\t"+str(count_total_refer_psamp)
                                                                +"\t"+str(count_tot_abstr_psamp)+"\t"+str(count_annot_abstr_psamp)+"\n")
                              tsv_total_refer_file.write(tot_num_of_refer_per_sample)
                                
                              # Print the total number of references found in the BibTex file being processed #
                              # and how many abstracts were annotated from the total available in the specific file #
                              print(infile.rsplit('.', 1)[0], ":", str(count_total_refer_psamp),"references found in total.",
                                    str(count_annot_abstr_psamp), "abstracts were annotated from", str(count_tot_abstr_psamp), "available.")

        # After the processing of the files is finished, print the results of the annotation #
        self.print_processing_results(count_tot_annot_abstr, count_papers, count_samples)

    def print_processing_results(self, count_tot_annot_abstr, count_papers, count_samples):       
        # Print the total number of the references found (in all BibTex files) # 
        print("Total number of references: ", count_papers)
        # Print the total number of the annotated abstracts (in all BibTex files) #                
        print("Total number of annotated abstracts: ", count_tot_annot_abstr)
        # Print the total number of the processed BibTex files # 
        print("Total number of BibTex files: ", count_samples)
        

