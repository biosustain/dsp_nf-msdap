#/usr/bin/env python3

import sys
import urllib.request
import hashlib

# this file requires a conversion table from NCBI tax ID to uniprot
# input is a mzTab file, as a loop, all species will be extracted, converted to uniprot syntax, and URLs will be generated.
# a complete fasta proteome will be downloaded and saved locally.
# the fasta will be filtered to also appear in a SwissProt only version.

print(sys.version)

# check if exists, and calculate md5
dictionary_raw_file = '~/nf/getstarted/temp/library/reference_proteomes.txt'

# Pick this URL from config file
urllib.request.urlretrieve("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/README", dictionary_raw_file)
# commandline point to mzTab file

# read file until header line that starts wiht Proteome_ID, export rest as tsv.
# extract Release date, etc.

dictionary_raw_md5 = 'void'
proteomelist_release = 'void'
proteomelist_speciescount = ''

tsvout = open('~/cfb/nf/getstarted/temp/library/conversion.tsv', 'w', encoding="utf-8")
with open(dictionary_raw_file, encoding="utf-8") as f:
    tsvparse = False
    for line in f:
        if line[0:7] == 'Release' :
            proteomelist_release = line
        elif line[0:10] == 'Statistics':
            proteomelist_speciescount += line
        elif line[0:11] == 'Proteome_ID':
            tsvparse = True
        elif line[0:2] != 'UP':
            tsvparse = False
        if tsvparse == True:
            tsvout.write(line)
tsvout.close()

print(proteomelist_release)
print(proteomelist_speciescount)

for file_name in [dictionary_raw_file,'~/cfb/nf/getstarted/temp/library/conversion.tsv']:
    with open(file_name, 'rb') as file_to_check:
        # read contents of the file
        data = file_to_check.read()    
        # pipe contents of the file through
        md5_returned = hashlib.md5(data).hexdigest()
        print(file_name, md5_returned)


# for line in dictionary_raw_file
# if line starts with Release
# save to variable along with statistics
# then when line starts with Proteome_ID, save rest to tsv file

