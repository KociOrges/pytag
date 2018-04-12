# ```pytag```
Automated identification of ontological terms in application area specific literature surveys
```diff
- Please note that the repository for this project is still under construction!
```

## Dependencies
- You will need python version 3.4.2 or newer versions to execute the software.
- The project also depends on some other modules such as ```bibtexparser 0.6.2``` and ```Inflect 0.2.5```. Happily, these will be installed automatically when following the commands below.
- We use [EXTRACT 2.0](http://extract.jensenlab.org/), a custom named entity recognition (NER) system to annotate the text contets with ontological terms.

## Installing
**Step 1: Cloning the repository**

Here you will download a copy of the code and place it somewhere in your directory.
```
$ mkdir repos
$ cd repos
$ git clone https://github.com/KociOrges/pytag
```
**Step 2: Installing the software using the setup.py file**
```
$ cd pytag
$ python setup.py install
```
**Step 3: Modify your search paths**

By default, ```pytag``` will be installed in the ```site-packages``` and ```bin``` directory of your python version. For this reason, you need to set your ```$PATH``` appropriately so that the software can be executed. Make sure that you have the following path added in your ```$PATH```:
```
/.pyenv/versions/3.X(>=4).Y(>=2)/bin
```


## Usage
Once that is done, you can start annotating BibTex files from the command line. We will assume that you already have the BibTex files that you want to annotate in the directory ```path_to_BibTex_files/```. We will also assume that you want to identify terms utilizing all the supported ontologies for your annotation. The identified terms are then described in the ```TSV``` table ```ontology_terms.tsv```. This can be done as follows:

```
$ pytag --input_dir path_to_BibTex_files/ --onto_types all --out_file ontology_terms.tsv
```

### All parameters
You can also specify the ontology/ies that you want to utilise for your annotation by using the associated numerical identifiers as decribed below:
* ```0```: ```Genes/proteins``` from the specified organism
* ```-1```: ```Small Molecule Compound``` identifiers
* ```-2```: ```NCBI Taxonomy``` entries
* ```-21```: ```Gene Ontology biological process``` terms
* ```-22```: ```Gene Ontology cellular component``` terms
* ```-23```: ```Gene Ontology molecular function``` terms
* ```-25```: ```BRENDA Tissue``` Ontology terms
* ```-26```: ```Disease Ontology``` terms
* ```-27```: ```Environment Ontology``` terms

For example, let's say that you would like to identify the *Environmental*, *Tissue* and *Disease* mentions in your BibTex files. This can be done as follows (the order of the numerical identifiers is irrelevant):

```
$ pytag --input_dir path_to_BibTex_files/ --onto_types -27 -25 -26 --out_file ontology_terms.tsv
```

## What does it do exactly?
Starting from a keyword search in PubMed database, the returned abstracts can be extracted and then imported into a citation management software, such as [EndNote](http://endnote.com/). Next, they are exported in BibTeX format, where every reference is annotated with a number of records including PubMed IDs. In pyTag pipeline, for each PubMed ID described in the BibTex files, the associated link in NCBI database is followed and the relevant abstract is extracted. Next, these abstracts are processed using a custom named entity recognition (NER) system called [EXTRACT 2.0](http://extract.jensenlab.org/). The system supports multiple ontologies and can recover the genes/proteins, small molecule compounds, organisms, environments, tissues, diseases, phenotypes and Gene Ontology terms in a given piece of text. After the collection and the annotation of the total number of abstracts is performed, a table describing the identified ontological terms is generated, which can next be subjected to statistical analysis for further exploration. 

## Why make this?
The volume of biomedical literature in electronic format has grown exponentially over the past few years. To explore this huge amount of data to reveal hidden patterns, there is a need to use automated textmining tools that can elucidate useful insights provided if the information is available in a structured format. With ontology-driven annotation of biomedical data gaining popularity in recent years and online databases offering metatags with rich textual information, it is now possible to textmine ontological terms and explore these aspects through downstream statistical analysis. The automated interpretation of literature data offered from ```pytag```, can reduce the amount of information to manageable set of deducable patterns from which it is easier to draw conclusions and can be helpful for systematic reviews. 

## Pipeline overview
Schematic of the workflow for the automated identification and analyses of ontological terms in literature data using ```pytag```: 
<img width="1004" alt="workflow" src="https://user-images.githubusercontent.com/30604050/38675005-4c84ab44-3e4e-11e8-83ec-91d51422c52d.png">

Schematic overview of ```pytag``` internal pipeline structure:
![pytag_internal_structure](https://user-images.githubusercontent.com/30604050/32101477-42bbf8ea-bb10-11e7-9069-e8b4c3bd25dd.png)

## Tutorial
We will run ```pytag``` using some BibTex files generated from a keyword search in PubMed database. Let's say that we are interested in exploring the content of ontological terms for the publications related to Crohn's Disease and Ulcerative Colitis in the context of Nutrition, for the years 2015 and 2016. For that purpose, in PubMed database we have searched for the Boolean keywords: ```(Crohn's AND Nutrition)``` and ```(Ulcerative Colitis AND Nutrition)``` between ```2015 and 2016```, to obtain the relevant literature. For each search, we have labelled and extracted the citations in external files, using the “Citation Manager” function in ```MEDLINE``` (tagged) format. Next, we have imported these files into ```EndNote```, to export them in BibTeX format where every reference is described with an associated PubMed ID. The PubMed ID is a unique identifier used in PubMed and assigned to each article record when it enters the PubMed system. **Before we run ```pytag```, we will need to make sure that our BibTex files contain in each of their references a record called ```Pubmed ID``` or ```Accession Number``` describing this unique identifier**. You can find a tutorial on how to edit the bibliographic styles in ```EndNote``` [here](http://libguides.usd.edu/content.php?pid=63203&sid=755800). **The references in the BibTex files should look like this:** 
```
@article{
   title = {Latest evidence on Crohn's Disease}, 
   journal = {Journal},
   volume = {14},
   number = {6},
   ...
   Pubmed ID = {27483748}, 
   DOI = {10.8902/h.kldu.2015.04.017},
   year = {2015},
   type = {Reference Type}
}
*The details of the article are all fake. This example just describes how BibTex files should look like before processing.
```
Here, we have put the generated BibTex files for each keyword searched inside the folder bibtex_example/. 

```
$ ls bibtex_example/
Crohn.Nutrition.2015.2016.bib			
UlcerativeColitis.Nutrition.2015.2016.bib
```

In our scenario, we assume that we are interested in annotating our literature with terms that are related to all the supported ontology types (in case we would like to specify only some particular types then we should replace the parameter 'all' with the relevant numerical identifiers as described in section Usage). We also define ```crohn_colitis_ontology_terms.tsv``` as the ```TSV``` file where the identified terms will be described. This can be done as follows:

```
$ pytag --input_dir bibtex_example/ --onto_types all --out_file crohn_colitis_ontology_terms.tsv
```

As the script is running, in the output you should be able to see which file is currently being annotated and for the references that no terms were identified in their abstract text content, a relevant message with their associated PubMed ID is also shown on the command line. After a BibTex file is processed, then the total number of references, the number of availabe and annotated abstracts are mentioned for the specific file. When the execution is completed for all the BibTex files, then the total number of references processed, the total number of the annotated abstracts and the number of BibTex files annotated from the pipeline are also shown on the command line:

```
$ pytag --input_dir bibtex_example/ --onto_types all --out_file crohn_colitis_ontology_terms.tsv
Processing file: 1 Crohn.Nutrition.2015.2016.bib
no annotation for reference with Pubmed ID:  26833290
no annotation for reference with Pubmed ID:  26917043
...
Crohn.Nutrition.2015.2016 : 676 references found in total. 607 abstracts were annotated from 630 available.
Processing file: 2 UlcerativeColitis.Nutrition.2015.2016.bib
...
UlcerativeColitis.Nutrition.2015.2016 : 463 references found in total. 429 abstracts were annotated from 443 available.
Total number of references:  1139
Total number of annotated abstracts:  1036
Total number of BibTex files:  2
```
Once the pipeline has finished processing, you will have the following contents in your home folder:
```
$ ls
bibtex_example
bibtex_files
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
UlcerativeColitis.Nutrition.2015.2016   25850835  perineal   Organism         138833
UlcerativeColitis.Nutrition.2015.2016   26419460  trim39     Genes/Proteins   ensmusp00000039790
UlcerativeColitis.Nutrition.2015.2016   26419460  traf6      Genes/Proteins   ensrnop00000006148
UlcerativeColitis.Nutrition.2015.2016   27281309  intestine  Tissue           bto:0000642
```

In the ```annotation_summary.tsv``` table you will find for each BibTex file, the number of references that were found, the number of the abstracts that were available for these references and the number of the abstracts that were finally annotated. The file should look like this:
```
$ cat annotation_summary.tsv 
	                        Total_number_of_references   Available_abstracts   Annotated_abstracts
Crohn.Nutrition.2015.2016	                       676	             630	           607
UlcerativeColitis.Nutrition.2015.2016	               463	             443	           429
```

After the steps above are completed, then we can easily import the file with the identified ontological terms into ```R software``` and generate a frequency table using the ```table()``` function to perform downstream analysis. In addition, in case we desire to assess temporal changes in literature from multiple keywords in a longitudinal setting, then the information provided in the ```annotation_summary.tsv``` can be useful in case we need to normalise our frequency data before doing statistics, based on e.g., the number of the annotated abstracts.

