#!/usr/bin/env python


# Third party modules #
import inflect

def extract_terms(terms_table, pmid, infile, tsv_file):
      """A method to replace the numerical identifiers used from the tagger for the
      supported entity types with their associated ontology entries. The identified
      terms for a given abstract text are assigned in a list and returned from the
      method to be saved in the final composite TSV table.
      """
      
      # Local variable used for the identified terms in the given abstract #
      linetofile = ''
      # 'Inflection' module is used to check for words/terms in plural form #
      engine=inflect.engine()
      
      # If the table with the annotated terms is not empty #
      if (len(terms_table) > 0 and '?xml version' not in terms_table):
             # Split the table based on newline character to extract #
             # the information related to each term #
             elements = terms_table.split("\n")

             # List used to check for duplicate terms based on their name #
             check_dupl_name = []
             # List used to check for duplicate terms based on their identifier #
             check_dupl_id = []
             # Iterate over each term found in the list #
             for el in elements:
                # Split the records for each term based on TAB character #
                # to obtain its name, entity type and identifier #
                lis = el.split("\t")
                lis_ch_sin = el.split("\t")
                # Check if the name for the investigated term is in singular form #
                lis_ch=str(engine.singular_noun(lis_ch_sin[0]))
                if(lis_ch != 'False'):
                      lis_ch_sin[0] = lis_ch
                """ Make sure that the list of the annotated terms does not include both
                plural and singular form for a term and that terms having the same identifiers
                are considered only once. """
                if((lis_ch_sin[0] not in check_dupl_name) and (lis[2] not in check_dupl_id)):
                      # Assing the associated ontology entries to the identified entity types #
                      if(lis[1] and int(lis[1]) > 0):
                         lis[1] = "Genes/Proteins"
                      elif(lis[1] and "-1" == lis[1] ):
                         lis[1] = "Chemical Compound"
                      elif(lis[1] and "-2" == lis[1]):
                         lis[1] = "Organism"
                      elif(lis[1] and "-25" == lis[1]):
                         lis[1] = "Tissue"
                      elif(lis[1] and "-26" == lis[1]):
                         lis[1] = "Disease"
                      elif(lis[1] and "-27" == lis[1]):
                         lis[1] = "Environment"
                      elif(lis[1] and "-22" == lis[1]):
                         lis[1] = "Cellular Component"
                      elif(lis[1] and "-21" == lis[1]):
                         lis[1] = "Biological Process"
                      elif(lis[1] and "-23" == lis[1]):
                         lis[1] = "Molecular Function"
                      # Assing the name of the BibTex file with the pmid, the name of the identified term, #
                      # its ontology entry and its identifier in a string variable #
                      linetofile = str(infile.rsplit('.', 1)[0]+"\t"+pmid+"\t"+lis[0]+"\t"+lis[1]+"\t"+lis[2]+"\n")
                      # Include this information in the composite TSV table #
                      tsv_file.write(linetofile)
                      # Update the according tables for any duplicate names found in the list of the identified terms #
                      check_dupl_name.append(lis_ch_sin[0])
                      # Update the according tables for any duplicate IDs found in the list of the identified terms #
                      check_dupl_id.append(lis[2])
      
      return linetofile
