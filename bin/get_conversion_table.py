#!/usr/bin/env python3

'''
______      _          _____      _                      ______ _       _    __                     
|  _  \    | |        /  ___|    (_)                     | ___ \ |     | |  / _|                    
| | | |__ _| |_ __ _  \ `--.  ___ _  ___ _ __   ___ ___  | |_/ / | __ _| |_| |_ ___  _ __ _ __ ___  
| | | / _` | __/ _` |  `--. \/ __| |/ _ \ '_ \ / __/ _ \ |  __/| |/ _` | __|  _/ _ \| '__| '_ ` _ \ 
| |/ / (_| | || (_| | /\__/ / (__| |  __/ | | | (_|  __/ | |   | | (_| | |_| || (_) | |  | | | | | |
|___/ \__,_|\__\__,_| \____/ \___|_|\___|_| |_|\___\___| \_|   |_|\__,_|\__|_| \___/|_|  |_| |_| |_|

website: https://multiomics-analytics-group.github.io/
project: https://github.com/biosustain/dsp_nf-msdap

@DTU Biosustain
'''

import os
import re
import urllib.request
import argparse
import pandas as pd

reference_proteomes_file_name = "reference_proteomes.txt"
conversion_table_file_name = "conversion_table.tsv"
#UniProt reference proteome table
uniprot_reference_url = "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/README"
#UniProt download fasta
uniprot_proteome_url = 'https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&includeIsoform=true&query=(proteome:UID)'


def download_reference_proteomes(url: str, reference_proteomes_dir: str, force: bool=False):
    '''
    Downloads UniProt reference proteomes containing the table with the mapping between
    UniProt proteome identifiers and NCBI taxonomic identifiers. When downloading, it 
    also extracts the mapping table (conversion table) to a file.
    
    params:
        str url: UniProt url with reference proteome file
        str reference_proteomes_dir: Directory where the reference proteomes and \
            conversion table can be found or should be stored
        bool force: Boolean defining whether the file should be downloaded even if \
            exists
            
    example:
        python get_conversion_table.py --proteomes reference --force False
    '''
    reference_proteomes_file = os.path.join(reference_proteomes_dir, reference_proteomes_file_name)
    if force or not os.path.exists(reference_proteomes_file):
        if not os.path.exists(reference_proteomes_dir):
            os.mkdir(reference_proteomes_dir)
        urllib.request.urlretrieve(url, reference_proteomes_file)
        
        extract_conversion_table(reference_proteomes_dir)

def extract_conversion_table(reference_proteomes_dir):
    '''
    Extracts the mapping table (conversion table) between UniProt proteome identifiers
    and NCBI taxonomic identifiers from the reference proteome file and stores them into 
    a file.
    
    params:
        str reference_proteomes_dir: Directory where the reference proteomes and \
            conversion table can be found or should be stored
    '''
    regex = r"=\s(\d+)"
    reference_proteomes_file = os.path.join(reference_proteomes_dir, reference_proteomes_file_name)
    conversion_table_file = os.path.join(reference_proteomes_dir, conversion_table_file_name)

    with open(reference_proteomes_file, 'r', encoding="utf-8") as f:
        n = 0
        for line in f:
            if line.startswith('Release'):
                proteomelist_release = line
                print(proteomelist_release)
            elif line.startswith("Statistics"):
                match = re.search(regex, line)
                if match:
                    n = int(match.group(1))
                    print(f"Proteomes stored:{n}")
            elif line.startswith('Proteome_ID'):
                header = line.rstrip().split("\t")
                break
        table_rows = range(0, n)
        ref_prot = pd.read_csv(f, sep="\t", header=0, skiprows = lambda x: x not in table_rows)
        ref_prot.columns = header
        
        with open(conversion_table_file, 'w', encoding="utf-8") as out:
            ref_prot.to_csv(out, sep='\t', header=True, index=False, doublequote=None)

def download_fasta(taxid: str, url: str, reference_proteomes_dir: str):
    '''
    Downloads from UniProt the fasta file for the taxid specified. This function
    requires reading from the conversion table the UniProt identifier associated 
    to the NCBI taxonomic identifier and downloading the file in compressed format.
    
    params:
        str taxid: NCBI taxonomic identifier
        str url: UniProt URL to download fasta file 
        str reference_proteomes_dir: Directory where the reference proteomes and \
            conversion table can be found or should be stored
    '''
    
    conversion_table_file = os.path.join(reference_proteomes_dir, conversion_table_file_name)
    conversion_df = pd.read_csv(conversion_table_file, sep="\t", dtype=str)
    uniprot_id = conversion_df.loc[conversion_df['Tax_ID'] == taxid, 'Proteome_ID'].values[0]
    url = url.replace('UID', str(uniprot_id))
    fastaname = os.path.join(reference_proteomes_dir, f'{taxid}.fasta.gz')
    urllib.request.urlretrieve(url, fastaname)

if __name__ == "__main__":
    # 3 parameters --taxid, --reference_proteomes and --force
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--proteomes", help="Path to file with the conversion between \
        NCBI taxids and UniProt proteome identifiers")
    parser.add_argument("-f", "--force", help="Whether or not force download of the reference \
        proteomes", default=False)
    parser.add_argument("-t", "--taxid", help="NCBI taxonomic identifier of interest", default=None)
    args = parser.parse_args()

    reference_proteomes = args.proteomes
    force_dwn = args.force
    taxid = args.taxid

    download_reference_proteomes(url=uniprot_reference_url,
                                 reference_proteomes_dir=reference_proteomes,
                                 force=force_dwn)
    if taxid is not None:
        output_file_path = os.path.join(reference_proteomes, f'proteome_{taxid}.fasta.gz')
        if not os.path.exists(output_file_path):
            download_fasta(taxid=taxid, url=uniprot_proteome_url,
                        reference_proteomes_dir=reference_proteomes)
