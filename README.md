# ```pyTag```
Automated identification of ontological terms in application area specific literature surveys
```diff
- Please note that the repository for this project is still under construction!
```

## Dependencies
- You will need python version 3.4.0 or newer versions to execute the software.
- The project also depends on some other modules such as ```bibtexparser 0.6.2``` for parsing the BibTex files and the ```Inflect 0.2.5``` package to check for words in plural form. Happily, these will be installed automatically when calling the pip command below.
- We use EXTRACT (http://extract.jensenlab.org/), a custom named entity recognition (NER) system to annotate the text contets with ontological terms.

## Installing
To install ```pyTag```  onto your machine, use the setup.py file:
```
$ python setup.py install
```

## Usage
Once that is done, you can start annotating BibTex files from the command line. We will assume that you already have the BibTex files that you want to annotate in the directory ```path_to_BibTex_files/```. We will also assume that you want to identify terms from all the supported ontologies for your annotation. The identified terms are then described in the ```TSV``` table ```ontology_terms.tsv```. This can be done as follows:

```
$ python pytag.py --input_dir path_to_BibTex_files/ --onto_types all --out_file ontology_terms.tsv
```

### All parameters
You can also specify the ontology/ies that you want to utilise for your annotation by using the associated numerical identifiers as decribed below:
* ```0```: ```Genes/proteins``` from the specified organism
* ```-1```: ```PubChem Compound``` identifiers
* ```-2```: ```NCBI Taxonomy``` entries
* ```-21```: ```Gene Ontology biological process``` terms
* ```-22```: ```Gene Ontology cellular component``` terms
* ```-23```: ```Gene Ontology molecular function``` terms
* ```-25```: ```BRENDA Tissue``` Ontology terms
* ```-26```: ```Disease Ontology``` terms
* ```-27```: ```Environment Ontology``` terms

For example, let's say that you would like to identify the Environment, Tissue and Disease mentions in your BibTex files. This can be done as follows (the order of the numerical identifiers is irrelevant):

```
$ python pytag.py --input_dir path_to_BibTex_files/ --onto_types -27 -25 -26 --out_file ontology_terms.tsv
```

## What does it do exactly?
Starting from a keyword search in PubMed database, the returned abstracts can be extracted and then imported into a citation management software, such as EndNote (http://endnote.com/). Next, they are exported in BibTeX format, where every reference is annotated with a number of records including PubMed IDs. In pyTag pipeline, for each PubMed ID described in the BibTex files, the associated link in NCBI database is followed and the relevant abstract is extracted. Next, these abstracts are processed using a custom named entity recognition (NER) system called EXTRACT. The system supports multiple ontologies and can list the PubChem Compounds, Environmental Ontology, NCBI Taxonomy, BRENDA Tissue Ontology, Disease Ontology, and Gene Ontology (biological process, cellular component, and molecular function) in a given piece of text. After the collection and the annotation of the total number of abstracts is performed, a table describing the identified ontological terms is generated, which can next be subjected to statistical analysis for further exploration.

## Why make this?
The volume of biomedical literature in electronic format has grown exponentially over the past few years. With the latest count of 27 million in 2017, Pubmed's search engine can find the MEDLINE database of references and abstracts on life sciences and biomedical topics using key concepts. To explore this huge amount of data to reveal hidden patterns, there is a need to use automated textmining tools that can elucidate useful insights provided if the information is available in a structured format. 

## Pipeline overview
Schematic of the workflow for the automated identification and analyses of ontological terms in literature data: 
![workflow](https://user-images.githubusercontent.com/30604050/28795721-d8093606-7632-11e7-82c1-ca86d2a7fedf.png)

## Tutorial
We will run pyTag using some BibTex files generated from a keyword search in PubMed database. Let's say that we were interested for the publications related to Crohn's Disease and Ulcerative Colitis in the context of Nutrition, for the years 2015 and 2016. For that purpose, in PubMed database we have searched for the Boolean keywords: (Crohn's AND Nutrition) and (Ulcerative Colitis AND Nutrition) between 2015 and 2016, to obtain the relevant literature. For each search, we have extracted and stored the citations in external files, using the “Citation Manager” function in MEDLINE (tagged) format. Next, we have imported these files into EndNote, to export them in BibTeX format, where every reference is also described with an associated PubMed ID.  
