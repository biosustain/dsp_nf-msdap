#/usr/bin/env python3

import sys
import urllib.request
import hashlib
import pandas as pd
import argparse 

# receive list of samples
parser = argparse.ArgumentParser()
# --input samplefile --output 
parser.add_argument("-l", "--library", help="library dir")
parser.add_argument("-t", "--taxid", help="taxid code")

# organism as command line parameter
# Get all samples and groups from cmd or input file 
args = parser.parse_args()

# this file requires a conversion table from NCBI tax ID to uniprot
# input is a mzTab file, as a loop, all species will be extracted, converted to uniprot syntax, and URLs will be generated.
# a complete fasta proteome will be downloaded and saved locally.
# the fasta will be filtered to also appear in a SwissProt only version.

library_dir = args.library
conversion_file = ''.join([library_dir,'/conversion.tsv'])
conversion_df = pd.read_csv( conversion_file ,sep="\t",dtype=str)

baseurl = 'https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&includeIsoform=true&query=%28%28proteome%3A'
# we can reduce complexity of link 
#baseurl = 'https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&includeIsoform=true&query='
# if so also remove suffix in urlretreive


taxid = str(args.taxid)

print(taxid)
uniprot = conversion_df.loc[conversion_df['Tax_ID'] == taxid, 'Proteome_ID']
print(uniprot)
upid = uniprot.item()
downloadlink = ''.join([baseurl,upid,'%29%29'])
fastaname = ''.join(['./library/proteome_',taxid,'.fasta.gz'])
urllib.request.urlretrieve(downloadlink, fastaname)
