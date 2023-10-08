#/usr/bin/env python3
import pandas as pd
import argparse 

# receive list of samples
parser = argparse.ArgumentParser()
# --input samplefile --output 
parser.add_argument("-i", "--input", help="sample.xlsx input file to be modified")
#parser.add_argument("-c", "--conditions", help="list of replicate conditions")
parser.add_argument("-r", "--replicate", help="full ordered list of all replicate conditions")

args = parser.parse_args()

# demo sample
samplefile = './samples.xlsx'
#samplefile = args.input

# demo list
#replicate_conditions = ["en","to","tre","nul"]
#replicate_conditions = args.conditions

# pseudo code: scale up the conditions to full sample list

# get sample count 
dfxl = pd.read_excel(samplefile, engine='openpyxl', sheet_name='samples')

sample_count = len(dfxl)


# read in sample2group dictionary from user yaml
replicate_conditions_list = args.replicate.split(" ")

dfxl['group'] = replicate_conditions_list 


dfxl.to_excel(samplefile, sheet_name='samples')

