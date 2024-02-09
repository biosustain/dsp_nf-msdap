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

import pandas as pd
import argparse


def read_sample_file(sample_file: str) -> pd.DataFrame:
    '''
    Read sample Excel file generated by MSDAP with columns
    sample_id / shortname / exclude
    params:
        str sample_file: path to the MSDAP samples Excel file
    return:
        DataFrame df: samples dataframe
    '''
    df = None
    with open(sample_file, 'rb') as f:
        df = pd.read_excel(f, sheet_name='samples')
        df = df.drop("group", axis=1)

    return df

def read_groups_file(groups_file: str):
    '''
    Read groups Excel file generated by the user specifying the conditions with columns:
    sample_id / group
    params:
        str groups_file: path to the groups Excel file
        
    return:
        DataFrame df: groups dataframe
    '''
    df = None
    with open(groups_file, 'rb') as f:
        df = pd.read_excel(f)

    return df

def merge_groups(samples: pd.DataFrame, groups: pd.DataFrame, output_file: str) -> pd.DataFrame:
    '''
    Add the groups to the sample file generating a file with columns
    sample_id / shortname / exclude / group
    params:
        DataFrame samples: dataframe with the experiment samples
        DataFrame groups: dataframe with the experiment groups (conditions)
        str output_file: path to the samples file
    '''
    df = samples.set_index("sample_id").join(groups.set_index("sample_id"))
    df.to_excel(output_file, sheet_name='samples')

if __name__ == "__main__":
    # receive list of samples
    parser = argparse.ArgumentParser()
    # --input samplefile --output 
    parser.add_argument("-i", "--input", help="sample.xlsx input file to be modified")
    parser.add_argument("-g", "--groups_file", help="mapping of samples and the group they belong to")
    args = parser.parse_args()
    sample_file = args.input
    groups_file = args.groups_file

    samples =  read_sample_file(sample_file=sample_file)
    groups = read_groups_file(groups_file=groups_file)
    merge_groups(samples=samples, groups=groups, output_file='samples.xlsx')
