#!/usr/bin/env Rscript

# ______      _          _____      _                      ______ _       _    __                     
# |  _  \    | |        /  ___|    (_)                     | ___ \ |     | |  / _|                    
# | | | |__ _| |_ __ _  \ `--.  ___ _  ___ _ __   ___ ___  | |_/ / | __ _| |_| |_ ___  _ __ _ __ ___  
# | | | / _` | __/ _` |  `--. \/ __| |/ _ \ '_ \ / __/ _ \ |  __/| |/ _` | __|  _/ _ \| '__| '_ ` _ \ 
# | |/ / (_| | || (_| | /\__/ / (__| |  __/ | | | (_|  __/ | |   | | (_| | |_| || (_) | |  | | | | | |
# |___/ \__,_|\__\__,_| \____/ \___|_|\___|_| |_|\___\___| \_|   |_|\__,_|\__|_| \___/|_|  |_| |_| |_|
#
#website: https://multiomics-analytics-group.github.io/
#project: https://github.com/biosustain/dsp_nf-msdap

#@DTU Biosustain

suppressPackageStartupMessages(library("argparse"))
### create parser object ###
parser <- ArgumentParser()
# parse essential information, speciffic and must be defined, no defaults here
# argparse cannot set NA so a better solution is to define numeric values as character here, and redefine them as.numeric in the R session
parser$add_argument("--filenamepath", type="character")
parser$add_argument("--fastafiles", type="character")
parser$add_argument("--samplefile", type="character")
parser$add_argument("--format", type="character")
# parse import information to overwrite default values
## spectronaut import
parser$add_argument("--confidence_threshold",  type="character",  default="0.01")
parser$add_argument("--use_normalized_intensities", type="logical", default="FALSE")
parser$add_argument("--use_irt", type="logical", default="TRUE")
parser$add_argument("--return_decoys", type="logical", default="FALSE")
parser$add_argument("--remove_shared_spectronaut_proteingroups", type="logical", default="FALSE")
parser$add_argument("--do_plot", type="logical", default="TRUE")
### to be prepared for other MS output formats
# params.r.load.diann.xyz
##### params.r.load.encyclopedia.xyz
# params.r.load.fragpipe_ionquant.xyz
# params.r.load.maxquant 
##### params.r.load.metamorpheus
## params.r.load.openms_mztab
##### params.r.load.openswath
##### params.r.load.peaks
##### params.r.load.skyline
# params.r.load.proteomediscoverer

parser$add_argument("--remove_lowconf", type="logical", default = "TRUE")
parser$add_argument("--one_psm_per_precursor", default = "")
parser$add_argument("--collapse_peptide_by", default = "sequence_modified")

# parse run (quickstart information)
parser$add_argument("--filter_min_detect", type="character", default="3")
parser$add_argument("--filter_min_quant", type="character", default="3")
parser$add_argument("--filter_fraction_detect", type="character", default="0.75")
parser$add_argument("--filter_fraction_quant", type="character", default="0.75")
parser$add_argument("--filter_by_contrast", type="logical", default="TRUE")

parser$add_argument("--norm_algorithm.vsn", type="logical", default="TRUE")
parser$add_argument("--norm_algorithm.vwmb", type="logical", default="FALSE")
parser$add_argument("--norm_algorithm.modebetween_protein", type="logical", default="TRUE")
parser$add_argument("--norm_algorithm.modebetween", type="logical", default="FALSE")
parser$add_argument("--norm_algorithm.rlr", type="logical", default="FALSE")
parser$add_argument("--norm_algorithm.msempire", type="logical", default="FALSE")

parser$add_argument("--norm_algorithm.by_group", type="logical", default="FALSE")
parser$add_argument("--norm_algorithm.all_group", type="logical", default="TRUE")
parser$add_argument("--norm_algorithm.by_contrast", type="logical", default="FALSE")

parser$add_argument("--rollup_algorithm", type="character", default="0") # maxlfq #### may change to logical for each option

parser$add_argument("--dea_algorithm.deqms", type="logical", default="TRUE")
parser$add_argument("--dea_algorithm.msempire", type="logical", default="TRUE")
parser$add_argument("--dea_algorithm.msqrob", type="logical", default="FALSE")
parser$add_argument("--dea_algorithm.ebayes", type="logical", default="FALSE")
parser$add_argument("--dea_algorithm.msqrobsum", type="logical", default="FALSE")

# join into array
parser$add_argument("--dea_qval_signif", type="numeric", default = "0.05")
parser$add_argument("--dea_fc_signif", default = "NA")

parser$add_argument("--dea_qvalue_threshold", type="numeric", default = "0.01")
parser$add_argument("--dea_log2foldchange_threshold", default = "NA")
parser$add_argument("--output_qc_report", type="logical", default = "TRUE")
parser$add_argument("--output_abundance_tables", type="logical", default = "TRUE")
parser$add_argument("--output_dir", type="character", default = "msdap_results")
parser$add_argument("--output_within_timestamped_subdirectory", type="logical", default = "TRUE")

### commandline variables parsed ###
args <- parser$parse_args()

filenamepath <- args$filenamepath #  link the output file or directory
fastafiles <- args$fastafiles
samplesfile <- args$samplefile
format <- args$format


### prepare arrays ###
# Note: Normalization happens sequentially, for current development setup this array is adequate. In the future we may asign integer instead of bool to order the methods.
norm_algorithm_1 <- c()
if(args$norm_algorithm.vsn){
	norm_algorithm_1 <- append(norm_algorithm_1, "vsn")
}
if(args$norm_algorithm.vwmb){
	norm_algorithm_1 <- append(norm_algorithm_1, "vwmb")
}
if(args$norm_algorithm.rlr){
	norm_algorithm_1 <- append(norm_algorithm_1, "rlr")
}
if(args$norm_algorithm.msempire){
	norm_algorithm_1 <- append(norm_algorithm_1, "msempire")
}
if(args$norm_algorithm.modebetween){
	norm_algorithm_1 <- append(norm_algorithm_1, "modebetween")
}

norm_algorithm_2 <- c()
if(args$norm_algorithm.modebetween_protein){
	norm_algorithm_2 <- append(norm_algorithm_2, "modebetween_protein")
}

# join peptide normalizations and protein normalization
norm_algorithm_0 <- c(norm_algorithm_1, norm_algorithm_2)



dea_algorithm_0 <- c()
if(args$dea_algorithm.deqms){
	dea_algorithm_0 <- append(dea_algorithm_0, "deqms")
}
if(args$dea_algorithm.msempire){
	dea_algorithm_0 <- append(dea_algorithm_0, "msempire")
}
if(args$dea_algorithm.msqrob){
	dea_algorithm_0 <- append(dea_algorithm_0, "msqrob")
}
if(args$dea_algorithm.ebayes){
	dea_algorithm_0 <- append(dea_algorithm_0, "ebayes")
}
if(args$dea_algorithm.msqrobsum){
	dea_algorithm_0 <- append(dea_algorithm_0, "msqrobsum")
}




### char 2 numeric - argparse cannot handle numeric mixed with NA, so this will take care of those inputs
args$dea_fc_signif = as.numeric(args$dea_fc_signif)
args$dea_log2foldchange_threshold = as.numeric(args$dea_log2foldchange_threshold)
args$confidence_threshold = as.numeric(args$confidence_threshold)
args$filter_min_detect = as.numeric(args$filter_min_detect)
args$filter_min_quant = as.numeric(args$filter_min_quant)
args$filter_fraction_detect = as.numeric(args$filter_fraction_detect)
args$filter_fraction_quant = as.numeric(args$filter_fraction_quant)
args$dea_qval_signif = as.numeric(args$dea_qval_signif)
args$dea_qvalue_threshold = as.numeric(args$dea_qvalue_threshold)



###### parser done

library(msdap)
library("readxl")


if (tolower(format) == "spectronaut") {
  dataset <- import_dataset_spectronaut(
    filename = filenamepath,
    confidence_threshold = args$confidence_threshold,
    use_normalized_intensities = args$use_normalized_intensities,
    use_irt = args$use_irt,
    return_decoys = args$return_decoys,
    remove_shared_spectronaut_proteingroups = args$remove_shared_spectronaut_proteingroups,
    do_plot = args$do_plot
  )
  print("spectronaut import OK")
} else if (tolower(format) == "metamorpheus") {
  dataset <- import_dataset_metamorpheus(
    path = filenamepath,
    protein_qval_threshold = 0.05,
    collapse_peptide_by = "sequence_modified"
  )
} else {
  print(format)
}

dataset <- import_fasta(
  dataset,
  files = fastafiles
)

dataset <- import_sample_metadata(dataset, samplesfile)

exp_design <- read_excel(samplesfile)
groups <- unique(as.list(exp_design$group))
combinations <- t(combn(groups, 2))
contrasts <- lapply(1:dim(combinations)[1], function(x) c(unlist(t(combinations[x,])[1, ])))

dataset <- setup_contrasts(dataset, contrast_list = contrasts)


dataset <- analysis_quickstart(dataset,
filter_min_detect = args$filter_min_detect , # 0, # each peptide must have a good confidence score in at least N samples per group
filter_min_quant = args$filter_min_quant , # 3,          # similarly, the number of reps where the peptide must have a quantitative value
filter_fraction_detect = args$filter_fraction_detect ,  # 0, # each peptide must have a good confidence score in at least 75% of samples per group
  filter_fraction_quant = args$filter_fraction_quant ,  # 0.75,  # analogous for quantitative values
  filter_by_contrast =  args$filter_by_contrast , # TRUE,     # only relevant if dataset has 3+ groups. For DEA at each contrast, filters and normalization are applied on the subset of relevant samples within the contrast for efficiency, see further MS-DAP manuscript. Set to FALSE to disable and use traditional "global filtering" (filters are applied to all sample groups, same data table used in all statistics)
  norm_algorithm =  norm_algorithm_0  , #  c("vsn", "modebetween_protein"), # normalization; first vsn, then modebetween on protein-level (applied sequentially so the MS-DAP modebetween algorithm corrects scaling/balance between-sample-groups)
  dea_algorithm = dea_algorithm_0 ,  # c("msempire"), # statistics; apply multiple methods in parallel/independently
  dea_qvalue_threshold =  args$dea_qvalue_threshold  , #  0.01, # threshold for significance of adjusted p-values in figures and output tables
  dea_log2foldchange_threshold = args$dea_log2foldchange_threshold, # NA, # threshold for significance of log2 foldchanges. 0 = disable, NA = automatically infer through bootstrapping
  output_qc_report = args$output_qc_report , #   TRUE, # optionally, set to FALSE to skip the QC report (not recommended for first-time use)
  output_abundance_tables = args$output_abundance_tables , #  TRUE, # optionally, set to FALSE to skip the peptide- and protein-abundance table output files
  output_dir = args$output_dir  , #  "msdap_results", # output directory, here set to "msdap_results" within your working directory. Alternatively provide a full path, eg; output_dir="C:/path/to/myproject",
  output_within_timestamped_subdirectory = args$output_within_timestamped_subdirectory)  # TRUE

print_dataset_summary(dataset)

##### Done  #####