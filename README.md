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
We will run ```pyTag``` using some BibTex files generated from a keyword search in PubMed database. Let's say that we were interested to explore the publications related to Crohn's Disease and Ulcerative Colitis in the context of Nutrition, for the years 2015 and 2016. For that purpose, in PubMed database we have searched for the Boolean keywords: ```(Crohn's AND Nutrition)``` and ```(Ulcerative Colitis AND Nutrition)``` between ```2015 and 2016```, to obtain the relevant literature. For each search, we have labelled and extracted the citations in external files, using the “Citation Manager” function in ```MEDLINE``` (tagged) format. Next, we have imported these files into ```EndNote```, to export them in BibTeX format where every reference is described with an associated PubMed ID. The PubMed ID is a unique identifier used in PubMed and assigned to each article record when it enters the PubMed system. Before we run ```pyTag```, we will need to make sure that our BibTex files contain in each of their references a record called ```PMID``` or ```Accession Number``` describing this unique identifier. The references in the BibTex files should look like this:
```
@article{
   title = {Latest evidence on Crohn's Disease},
   journal = {Journal},
   volume = {14},
   number = {6},
   ...
   PMID = {27483748},
   DOI = {10.8902/h.kldu.2015.04.017},
   year = {2015},
   type = {Ref–rence Type}
}
```
Here, we have put the generated BibTex files for each keyword search inside the folder BibTex files/.

```
<b> $ ls</b> 
BibTex files	
setup.py
pytag.py
$ ls BibTex files/
Crohn.Nutrition.2015.2016.bib			
Ulcerative.Colitis.Nutrition.2015.2016.bib
```

In our scenario, we assume that we are interested to annotate our literature with terms that are related to all the supported ontology types (in case we would like to specify only some particular types then we should replace parameter 'all' with the relevant numerical identifiers as described in section Usage). We also define ```crohn_colitis_ontology_terms.tsv``` as the ```TSV``` file where the identified terms will be described. This can be done as follows:

```
$ python pytag.py --input_dir BibTex_files/ --onto_types all --out_file crohn_colitis_ontology_terms.tsv
```

As the script is running, in the output you should be able to see which file is currently being annotated and for the references that no terms were identified in their abstract text content, a relevant message with their associated PubMed ID is also shown on the command line. After a BibTex file is processed, then the total number of references, the number of availabe and annotated abstracts are mentioned for the specific file. When the execution is completed for all the BibTex files, then the total number of references processed, the total number of the annotated abstracts and the number of BibTex files annotated from the pipeline are also shown on the command line:

```
$ python pytag.py --input_dir BibTex files/ --onto_types all --out_file crohn_colitis_ontology_terms.tsv
Processing file: 1 Crohn.Nutrition.2015.2016.bib
no annotation for reference with PubMed ID:  26833290
no annotation for reference with PubMed ID:  26917043
...
Crohn.Nutrition.2015.2016 : 676 references found in total. 603 abstracts were annotated from 630 available.
Processing file: 2 Ulcerative.Colitis.Nutrition.2015.2016.bib
...
Ulcerative.Colitis.Nutrition.2015.2016 : 463 references found in total. 424 abstracts were annotated from 443 available.
Total number of references:  1139
Total annotated abstracts:  1027
Total tested files:  2
```
Once the pipeline has finished processing, you will have the following contents in your home folder:
```
$ ls
BibTex files
setup.py
pytag.py
crohn_colitis_ontology_terms.tsv
annotation_summary.tsv
```
The ```crohn_colitis_ontology_terms.tsv``` is the most interesting file and contains the ontology terms identified in the references of each BibTex file, followed with the associated PubMed ID of the abstract they were found in each case. For each term, the relevant ontology entry is mentioned followed with the associated identifier. The ```TSV``` file should look like this:
```
$ cat crohn_colitis_ontology_terms.tsv
Crohn.Nutrition.2015.2016   26011900  cancer                  Disease              doid:162
Crohn.Nutrition.2015.2016   26742586  proteobacteria          Organism	           1224
Crohn.Nutrition.2015.2016   26742586  inflammatory response   Biological Process   go:0006954
Crohn.Nutrition.2015.2016   26742586  e. coli                 Organism             110766
Crohn.Nutrition.2015.2016   25969456  4-cd                    Chemical Compound	   cids44608013
...
Ulcerative.Colitis.Nutrition.2015.2016   25850835  perineal   Organism         138833
Ulcerative.Colitis.Nutrition.2015.2016   26419460  trim39     Genes/Proteins   ensmusp00000039790
Ulcerative.Colitis.Nutrition.2015.2016   26419460  traf6      Genes/Proteins   ensrnop00000006148
Ulcerative.Colitis.Nutrition.2015.2016   27281309  intestine  Tissue           bto:0000642
```

In the ```annotation_summary.tsv``` table you will find for each BibTex file, the number of references that were found, the number of the abstracts that were available for these references and the number of the abstracts that were finally annotated ( this information can be useful in case we need to perform statistical analysis on the metadata and we would consider e.g., the number of the annotated abstracts for normalising our frequency data obtained from the ```crohn_colitis_ontology_terms.tsv``` table). The file should look like this:
```
$ cat annotation_summary.tsv 
	                        Total_number_of_references   Available_abstracts   Annotated_abstracts
Crohn.Nutrition.2015.2016	                       676	             630	           603
Ulcerative.Colitis.Nutrition.2015.2016	               463	             443	           424
```
