# pyTag
Automated identification of ontological terms in application area specific literature surveys

# Dependencies
- You will need python version 3.4.0 or newer versions to execute the software.
- The pipeline requires also bitexparser 0.6.2 for parsing the BibTex files. You can download and install this from here: https://github.com/sciunto-org/python-bibtexparser
- The tool makes use of inflection package to check for words in plural form. You can get and install this package from here: https://github.com/jpvanhal/inflection
- We use EXTRACT (http://extract.jensenlab.org/), a custom named entity recognition (NER) system to annotate the text contets with ontological terms.

# Usage
After you have finished with the required packages, you can start annotating BibTex files from the command line. This can be done as follows:

$ pytag -i path_to_bibtex_files/ -o onto_terms.tsv

# What does it do exactly?
Starting from a keyword search in PubMed database, the returned abstracts can be extracted and then imported into a citation management software, such as EndNote (http://endnote.com/). Next, they are exported in BibTeX format, where every reference is annotated with a number of records including PubMed IDs. In pyTag pipeline, for each PubMed ID described in the BibTex files, the associated link in NCBI database is followed and the relevant abstract is extracted. Next, these abstracts are processed using a custom named entity recognition (NER) system called EXTRACT. The system supports multiple ontologies and can list the PubChem Compounds, Environmental Ontology, NCBI Taxonomy, BRENDA Tissue Ontology, Disease Ontology, and Gene Ontology (biological process, cellular component, and molecular function) in a given piece of text. After the collection and the annotation of the total number of abstracts is performed, an abundance table of ontological terms is generated, which can next be subjected to statistical analysis.

# Pipeline overview
Schematic of the workflow for the automated identification and analyses of ontological terms in literature data: 
<p align="center">
  <img src="/Users/kociorges/Desktop/pyTag_figures/Figures for paper/Figure_1.pdf" width="350"/>
</p>
