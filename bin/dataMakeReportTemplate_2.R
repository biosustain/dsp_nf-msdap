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


arg <- commandArgs(TRUE)
filenamepath <- arg[1] #  link the output file
fastafiles <- arg[2]
samplesfile <- arg[3]
format <- arg[4]

library(msdap)
library("readxl")


if (tolower(format) == "spectronaut") {
  dataset <- import_dataset_spectronaut(
    filename = filenamepath,
    confidence_threshold = 0.01,
    use_normalized_intensities = FALSE,
    use_irt = TRUE,
    return_decoys = FALSE,
    remove_shared_spectronaut_proteingroups = FALSE,
    do_plot = TRUE)
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
filter_min_detect = 3, # each peptide must have a good confidence score in at least N samples per group
filter_min_quant = 3,          # similarly, the number of reps where the peptide must have a quantitative value
filter_fraction_detect = 0.75, # each peptide must have a good confidence score in at least 75% of samples per group
  filter_fraction_quant = 0.75,  # analogous for quantitative values
  filter_by_contrast = TRUE,     # only relevant if dataset has 3+ groups. For DEA at each contrast, filters and normalization are applied on the subset of relevant samples within the contrast for efficiency, see further MS-DAP manuscript. Set to FALSE to disable and use traditional "global filtering" (filters are applied to all sample groups, same data table used in all statistics)
  norm_algorithm = c("vsn", "modebetween_protein"), # normalization; first vsn, then modebetween on protein-level (applied sequentially so the MS-DAP modebetween algorithm corrects scaling/balance between-sample-groups)
  dea_algorithm = c("msempire"), # statistics; apply multiple methods in parallel/independently
  dea_qvalue_threshold = 0.01, # threshold for significance of adjusted p-values in figures and output tables
  dea_log2foldchange_threshold = NA, # threshold for significance of log2 foldchanges. 0 = disable, NA = automatically infer through bootstrapping
  output_qc_report = TRUE, # optionally, set to FALSE to skip the QC report (not recommended for first-time use)
  output_abundance_tables = TRUE, # optionally, set to FALSE to skip the peptide- and protein-abundance table output files
  output_dir = "msdap_results", # output directory, here set to "msdap_results" within your working directory. Alternatively provide a full path, eg; output_dir="C:/path/to/myproject",
  output_within_timestamped_subdirectory = TRUE)

print_dataset_summary(dataset)

##### Done  #####