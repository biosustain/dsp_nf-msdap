#/usr/bin/env python3

import sys
import urllib.request
import hashlib
import pandas as pd
import argparse 

# receive list of samples
parser = argparse.ArgumentParser()
# --input samplefile --output 
parser.add_argument("-c", "--conversion", help="conversion_file")
parser.add_argument("-m", "--mztab", help="mztab_file")

# organism as command line parameter
# Get all samples and groups from cmd or input file 
args = parser.parse_args()

# this file requires a conversion table from NCBI tax ID to uniprot
# input is a mzTab file, as a loop, all species will be extracted, converted to uniprot syntax, and URLs will be generated.
# a complete fasta proteome will be downloaded and saved locally.
# the fasta will be filtered to also appear in a SwissProt only version.

print(sys.version)

conversion_file = args.conversion
conversion_df = pd.read_csv( conversion_file ,sep="\t",dtype=str)

mztab = args.mztab
if len(sys.argv) > 1:
    mztab = sys.argv[1]
#tax2up_dict = conversion_df.to_dict(orient='records' ??? 'Tax_ID' , 'Proteome_ID')

# import mzTab file elements, or utilize library to retreive values
# pyOpenMS ?

print(mztab)
specieslist = []
with open(mztab, encoding="utf-8") as f:
    checkinfo = False
    for line in f:
        if line[0:3] == 'MTD':
            checkinfo = True
        else:
            checkinfo = False
        if checkinfo == True:
            linelist = line.split("\t")
            if linelist[1][0:7] == 'sample[':
                samplespecies = linelist[1].split("-")
                if samplespecies[1][0:7] == 'species':
                    species = linelist[2].split(",")
                    print(species)
                    taxid = species[1].strip()
                    specieslist.append(taxid)

print(specieslist)

proteomelink = []
baseurl = 'https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&includeIsoform=true&query=%28%28proteome%3A'
# we can reduce complexity of link 
#baseurl = 'https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&includeIsoform=true&query='
# if so also remove suffix in urlretreive

uniprotlist = []
for taxid in specieslist:
    uniprot = conversion_df.loc[conversion_df['Tax_ID'] == taxid, 'Proteome_ID']
    print(uniprot)
    upid = uniprot.item()
    uniprotlist.append(upid)
    downloadlink = ''.join([baseurl,upid,'%29%29'])
    proteomelink.append(downloadlink)
    fastaname = ''.join(['./library/proteomes/proteome_',taxid,'.fasta.gz'])
    urllib.request.urlretrieve(downloadlink, fastaname)
