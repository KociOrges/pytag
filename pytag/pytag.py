#!/usr/bin/env python

# Built-in modules #
from sys import argv
import argparse

# Internal modules #
from pytag.analysis import process

def main():
      # Mandatory arguments and help description #
      parser = argparse.ArgumentParser(description='This is a pipeline to annotate PubMed literature data with ontological terms.')
      parser.add_argument('--input_dir', help='The BibTex/txt file/s to process in the specified directory.', required=True)
      parser.add_argument('--onto_types', help='The ontologies to be used for annotation [0:Genes/Proteins, -1:PubChem Compound identifiers, -2:NCBI Taxonomy entries, -21:Gene Ontology biological process terms, -22:Gene Ontology cellular component terms, -23: Gene Ontology molecular function terms, -25: BRENDA Tissue Ontology terms, -26: Disease Ontology terms, -27: Environment Ontology terms. ]', default='all', nargs='+', choices=['all','0','-1','-2','-21','-22','-23','-25','-26','-27'], required=True)
      parser.add_argument('--out_file', help='Output name for the TSV table with the annotated terms.', required=True)
      args = parser.parse_args()

      onto_types_l = []
      if(args.onto_types):
            onto_types_l = set(args.onto_types)
            onto_types_l = form_entity_types(onto_types_l)

      # Run the pipeline #
      process(args.input_dir, onto_types_l, args.out_file)

def form_entity_types(ontotypes):
      # Insert the '+' symbol between the parameteres so that they can be identified from the tagger #
      onto_types_l = set(ontotypes)
      onto_types_l = list(onto_types_l)
      onto_types_l.sort()

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
