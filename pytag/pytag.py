#!/usr/bin/env python

# Built-in modules #
from sys import argv
import argparse

# Internal modules #
from pytag.analysis import Analysis

def main():
      # Mandatory arguments and help description #
      parser = argparse.ArgumentParser(description='This is a pipeline to annotate PubMed abstract texts with ontological terms.')
      parser.add_argument('--input_dir', help='The BibTex/txt file/s to process in the specified directory.', required=True)

      # Available choices and help description # 
      onto_types_parameters = {
          "--onto_types" : "The ontologies to be used for annotation."
                            + " 0:Genes/Proteins,"
                            + "-1:Small Molecule Compound identifiers,"
                            + "-2:NCBI Taxonomy entries,"
                            + "-21:Gene Ontology biological process terms,"
                            + "-22:Gene Ontology cellular component terms,"
                            + "-23:Gene Ontology molecular function terms,"
                            + "-25:BRENDA Tissue Ontology terms,"
                            + "-26:Disease Ontology terms,"
                            + "-27:Environment Ontology terms,"
                            + "all:Select all types"         
      }

      onto_types_choices=['0',
                        '-1',
                        '-2',
                        '-21',
                        '-22',
                        '-23',
                        '-25',
                        '-26',
                        '-27',
                        'all']

      # Parse it #
      for param, hlp in onto_types_parameters.items():
           parser.add_argument(param, help=hlp, nargs='+', choices= onto_types_choices, required=True)
      parser.add_argument('--out_file', help='Output name for the TSV table with the annotated terms.', required=True)
      args = parser.parse_args()

      # Call the function to form the numerical identifiers #
      if(args.onto_types):
            onto_types_formed = set(args.onto_types)
            onto_types_formed = form_entity_types(onto_types_formed)
      # Run the pipeline #
      Analysis(args.input_dir, onto_types_formed, args.out_file).process()
      

def form_entity_types(ontotypes):
      """A method to form the numerical identifiers appropriately for further processing"""
      onto_types_l = set(ontotypes)
      onto_types_l = list(onto_types_l)

      # Sort the numerical identifiers #
      onto_types_l.sort()

      # Insert the '+' symbol between the identifiers so that they can be used from the tagger #
      if(onto_types_l[0] == 'all'):
            ent_type_plus = '0'
            for ent_type in ['-1','-2','-21','-22','-23','-25','-26','-27']:
                  ent_type_plus = ent_type_plus + '+'.strip() + ent_type.strip()
      else:
            ent_type_plus = onto_types_l[0]
            for index, ent_type in enumerate(onto_types_l):
                  if(index > 0):
                        ent_type_plus = ent_type_plus + '+'.strip() + ent_type.strip()

      return ent_type_plus
                     
if __name__ == '__main__':
   main()
