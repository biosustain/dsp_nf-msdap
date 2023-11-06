#!/usr/bin/env python3

# take ALL fasta files and concatenate them into a single .fasta.gz file

#### cat file1.gz file2.gz file3.gz > allfiles.gz 


### read in user fasta files along with all downloaded proteome fasta files


with open(..., 'wb') as wfp:
  for fn in filenames:
    with open(fn, 'rb') as rfp:
      shutil.copyfileobj(rfp, wfp)
