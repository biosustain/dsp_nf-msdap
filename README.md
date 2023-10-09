# dsp_nf-msdap
Nextflow pipeline for MS-DAP, a downstream pipeline to generate statistical PDF reports for MS data

This repository aims to serve as a headless launcher for msdap - https://github.com/ftwkoopmans/msdap 

This very early development verion is only compatible with Spectronaut output, but all formats supported by msdap will be compatible with the final version.

to generate a pdf report with MS-DAP, the following are needed:

* Mass Spec report as would be needed for MS DAP.
* Fasta file with proteome / TAXID for species to autodownload from Uniprot.
* ordered list of replicate group names.

The enviromnent running this script will need following dependencies:

* Nextflow
* R installation with MS-DAP
* python3 with pandas


Example to initiate this pipeline (9606 indicates that proteome for human will be downloaded):

nextflow dsp_nf-msdap/flow_main.nf \
--format spectronaut \
--file spectronaut_out_report.csv \
--taxid 9606 \
--library ./library \
-params-file ./params.yaml



content of params.yaml:
```
groups:
  condition_a
  condition_a
  condition_a
  condition_b
  condition_b
  condition_b
```