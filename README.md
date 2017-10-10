# pyTag
Automated identification of ontological terms in application area specific literature surveys
```diff
- Please note that the repository for this project is still under construction!
```

# Dependencies
- You will need python version 3.4.0 or newer versions to execute the software.
- The project also depends on some other modules such as bitexparser 0.6.2 for parsing the BibTex files and the Inflect 0.2.5 package to check for words in plural form. Happily, these will be installed automatically when calling the pip command below.
- We use EXTRACT (http://extract.jensenlab.org/), a custom named entity recognition (NER) system to annotate the text contets with ontological terms.

# Usage
After you have finished with the required packages, you can start annotating BibTex files from the command line. This can be done as follows:

```
$ pytag -i path_to_bibtex_files/ -o onto_terms.tsv
```

# What does it do exactly?
Starting from a keyword search in PubMed database, the returned abstracts can be extracted and then imported into a citation management software, such as EndNote (http://endnote.com/). Next, they are exported in BibTeX format, where every reference is annotated with a number of records including PubMed IDs. In pyTag pipeline, for each PubMed ID described in the BibTex files, the associated link in NCBI database is followed and the relevant abstract is extracted. Next, these abstracts are processed using a custom named entity recognition (NER) system called EXTRACT. The system supports multiple ontologies and can list the PubChem Compounds, Environmental Ontology, NCBI Taxonomy, BRENDA Tissue Ontology, Disease Ontology, and Gene Ontology (biological process, cellular component, and molecular function) in a given piece of text. After the collection and the annotation of the total number of abstracts is performed, a table describing the identified ontological terms is generated, which can next be subjected to statistical analysis for further exploration.

# Why make this?
The volume of biomedical literature in electronic format has grown exponentially over the past few years. With the latest count of 27 million in 2017, Pubmed's search engine can find the MEDLINE database of references and abstracts on life sciences and biomedical topics using key concepts. To explore this huge amount of data to reveal hidden patterns, there is a need to use automated textmining tools that can elucidate useful insights provided if the information is available in a structured format. 

# Pipeline overview
Schematic of the workflow for the automated identification and analyses of ontological terms in literature data: 
![workflow](https://user-images.githubusercontent.com/30604050/28795721-d8093606-7632-11e7-82c1-ca86d2a7fedf.png)
