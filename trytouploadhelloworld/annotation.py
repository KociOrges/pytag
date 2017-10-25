#!/usr/bin/env python

# Built-in modules #
from urllib.request import urlopen
import urllib.request
from urllib.error import URLError, HTTPError
import http.client


def annotate_abstract(address, abstract, ontotypes):
      """ A method to identify and annotate the ontological terms in the collected abstract. The
      abstract is processed using a custom named entity recognition (NER) system called EXTRACT.
      The system supports multiple ontologies and can recover the Genes/Proteins, PubChem Compounds,
      Environmental Ontology, NCBI Taxonomy, BRENDA Tissue Ontology, Disease Ontology, and Gene Ontology
      (biological process, cellular component, and molecular function) in a given piece of text.
      This information is given in the form of a TSV table.
      """

      # Local variables to store the identified terms #
      terms_table = ''
      tsvdata = ''

      # If the asbtract for the examined reference is not available in the BibTex file, #
      # then follow the associated address in PubMed database to collect the text #
      if not abstract:
            try:
                  collect_abstr = urllib.request.urlopen(address)
            except HTTPError as e:
                  print('HTTPError = ' + str(e.code)+address)
            except URLError as e:
                  print('URLError = ' + str(e.reason))
            else:
                  # If everything is fine with the link then read the records for the #
                  # examined reference and assign them in a string variable #
                  data = str(collect_abstr.read())
                  # Locate the beginning of the abstract text within the records #
                  text_start = data.find('<AbstractText')
                  countchar = 0
                  startchar = text_start

                  # If an abstract is available then locate also where it ends #
                  if(text_start != -1):
                        for cha in range(startchar,len(data)):
                               ch=data[startchar:startchar+1]
                               if(ch == '>'):
                                   countchar=startchar
                                   break
                               startchar = startchar + 1
                               text_end = data.find('</AbstractText>')

                  # If the beginning and ending points of the abstract were specified then process the text #                           
                  if(text_start != -1 and text_end != -1):
                        # Collect only the absract text #
                        abstract = data[startchar+1 : text_end]
                        # The tagger uses '+' instead of the space character, so replace it #
                        abstract = abstract.replace(" ", "+")
                        # Remove any newline characters #
                        if "\n" in abstract:
                            abstract = abstract.replace("\n", "");
                        elif "#" in abstract:
                            abstract = abstract.replace("#", "");

                        # The tagger has a limit in the length of the text it can process. #
                        # If more than 6000 characters the text is truncated. #
                        len_abstr = len(abstract)
                        if(len_abstr > 6000):
                              print("- abstract length too long: ", len(abstract), ". Truncated to 6000 chars.")
                              abstract = abstract[:6000]

                        # Load the abstract text in the tagger for annotation #
                        tagger = 'http://tagger.jensenlab.org/GetEntities?document='+abstract+'&entity_types='+ontotypes+'&auto_detect=0&format=tsv'
                        try:
                              # Collect the annotation data #
                              tsvdata = urllib.request.urlopen(tagger)
                        except HTTPError as e:
                              print('HTTPError = ' + str(e.code)+address)
                        except URLError as e:
                              print('URLError = ' + str(e.reason))
                        else:
                              # Convert the annotation data to lower case and assign them to a string variable  #
                              terms_table = str(tsvdata.read(), "utf-8").lower()
      # If the abstract is collected from the BibText file #
      else:
            # The tagger uses '+' instead of the space character, so replace it #
            abstract = abstract.replace(" ", "+")
            # Remove any newline characters #
            if "\n" in abstract:
                abstract = abstract.replace("\n", "");
            elif "#" in abstract:
                abstract = abstract.replace("#", "");

            # The tagger has a limit in the length of the text it can process. #
            # If more than 6000 characters the text is truncated. #
            len_abstr = len(abstract)
            if(len_abstr > 6000):
                  print("- abstract length too long: ", len(abstract), ". Truncated to 6000 chars.")
                  abstract = abstract[:6000]

            # Load the abstract text in the tagger for annotation #
            tagger = 'http://tagger.jensenlab.org/GetEntities?document='+abstract+'&entity_types='+ontotypes+'&auto_detect=0&format=tsv'
            try:
                  # Collect the annotation data #
                  tsvdata = urllib.request.urlopen(tagger)
            except HTTPError as e:
                  print('HTTPError = ' + str(e.code))
            except URLError as e:
                  print('URLError = ' + str(e.reason))
            else:
                  # Convert the annotation data to lower case and assign them to a string variable  #
                  terms_table = str(tsvdata.read(), "utf-8").lower()

      # Return the table with the annotation data #            
      return terms_table
