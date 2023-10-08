## setup https://github.com/ftwkoopmans/msdap/blob/master/doc/userguide.md#spectronaut
# we are testing the functionality of processing spectronaut data

## This script is a development version and is only working with Spectronaut output at the moment

###############################################################################
######### Set working directory and input file linking ########################
###############################################################################

setwd('./') # Set working directory and execute to have Rstudio autocomplete

###############################################################################
arg<-commandArgs(TRUE)
# set commandline param 1
filenamepath = arg[1] #  link the output file


###############################################################################
## FASTA file or files: an array of filenames, these should be the full path ##
###############################################################################


# set command line param 2
fastafiles = arg[2]
#c('','')
###############################################################################


library(msdap)



# change to overwrite / append

dataset <- import_dataset_spectronaut(
   filename = filenamepath,
   confidence_threshold = 0.01,
   use_normalized_intensities = FALSE,
   use_irt = TRUE,
   return_decoys = FALSE,
   remove_shared_spectronaut_proteingroups = FALSE,
   do_plot = TRUE
 )


dataset <- import_fasta(
  dataset,
  files = fastafiles
)

#write_template_for_sample_metadata(dataset, "samples.xlsx", overwrite = FALSE)


# finally, import your updated sample metadata file
dataset = import_sample_metadata(dataset, "samples.xlsx")

###############################################################################
## define contrasts for differential expression/detection analysis         ####
## you must use precisely the same names as defined for groups in the xlsx #### 
###############################################################################

dataset = setup_contrasts(dataset, 
                          contrast_list = list(
                            c("a","b")
                            )
)

###############################################################################
### Below is the default parameters to run and generate report, once     ######
###  specified, if anything else than default is desired, the rest can   ######
###  be executed in one go, including the print_dataset_summary and the  ######
###  pdf report should appear in a few hours. This script is done.       ######
###  Additional data may be generated with our in-house scripts.         ######
###############################################################################



# At the following step, an online request is made, windows defender firewall blocks,
# not sure about the reason/consequence

# 6) Main function that runs the entire pipeline
# for DIA, recommended settings are defined below, selecting only peptides that were confidently detected/identified in most samples
# for DDA, 'confident detection' relies on MS/MS which may be more rare (relying on match-between-runs instead)
# so for DDA we recommend to set no or minimal requirements on 'detect' parameters; "filter_fraction_detect = 0" and "filter_min_detect = 0" (or 1 if you want at least 1 MS/MS detect per peptide per sample group)

dataset = analysis_quickstart(
  dataset,
  filter_min_detect = 3,         # each peptide must have a good confidence score in at least N samples per group
  filter_min_quant = 3,          # similarly, the number of reps where the peptide must have a quantitative value
  filter_fraction_detect = 0.75, # each peptide must have a good confidence score in at least 75% of samples per group
  filter_fraction_quant = 0.75,  # analogous for quantitative values
  filter_by_contrast = TRUE,     # only relevant if dataset has 3+ groups. For DEA at each contrast, filters and normalization are applied on the subset of relevant samples within the contrast for efficiency, see further MS-DAP manuscript. Set to FALSE to disable and use traditional "global filtering" (filters are applied to all sample groups, same data table used in all statistics)
  norm_algorithm = c("vsn", "modebetween_protein"), # normalization; first vsn, then modebetween on protein-level (applied sequentially so the MS-DAP modebetween algorithm corrects scaling/balance between-sample-groups)
  dea_algorithm = c("msempire", "msqrob"), # statistics; apply multiple methods in parallel/independently
  dea_qvalue_threshold = 0.01,                      # threshold for significance of adjusted p-values in figures and output tables
  dea_log2foldchange_threshold = NA,                # threshold for significance of log2 foldchanges. 0 = disable, NA = automatically infer through bootstrapping
  output_qc_report = TRUE,                          # optionally, set to FALSE to skip the QC report (not recommended for first-time use)
  output_abundance_tables = TRUE,                   # optionally, set to FALSE to skip the peptide- and protein-abundance table output files
  output_dir = "msdap_results",                     # output directory, here set to "msdap_results" within your working directory. Alternatively provide a full path, eg; output_dir="C:/path/to/myproject",
  output_within_timestamped_subdirectory = TRUE )


print_dataset_summary(dataset)

##### Done  #####

