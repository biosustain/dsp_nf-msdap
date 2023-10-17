#!/usr/bin/env python3
import os
import sys
import urllib.request
import hashlib
import argparse 

# receive list of samples
parser = argparse.ArgumentParser()
# --linrary
parser.add_argument("-l", "--library", help="parh to library folder for storing conversion file and proteome fasta files")

args = parser.parse_args()


# this file requires a conversion table from NCBI tax ID to uniprot
# input is a mzTab file, as a loop, all species will be extracted, converted to uniprot syntax, and URLs will be generated.
# a complete fasta proteome will be downloaded and saved locally.
# the fasta will be filtered to also appear in a SwissProt only version.

print(sys.version)

# check if exists, and calculate md5
library_folder = args.library
dictionary_raw_file = ''.join([library_folder, '/reference_proteomes.txt'])
conversion_table = ''.join([library_folder, '/conversion.tsv'])
# if exists README // conversion table
# md5 sum compare?

# check exists conversion
if not os.path.exists(library_folder):
    os.mkdir(library_folder)

if os.path.exists(dictionary_raw_file):
    md5_returned = hashlib.md5(dictionary_raw_file).hexdigest()
    print(md5_returned)
else:
    urllib.request.urlretrieve("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/README", dictionary_raw_file)


if os.path.exists(conversion_table):
    md5_returned = hashlib.md5(conversion_table).hexdigest()
    print(md5_returned)
else:
    # read file until header line that starts wiht Proteome_ID, export rest as tsv.
    # extract Release date, etc.
    dictionary_raw_md5 = 'void'
    proteomelist_release = 'void'
    proteomelist_speciescount = ''
    tsvout = open(conversion_table, 'w', encoding="utf-8")
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
    for file_name in [dictionary_raw_file,conversion_table]:
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

