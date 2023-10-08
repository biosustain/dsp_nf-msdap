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


dataset <- import_dataset_spectronaut(
  filename = filenamepath,
  confidence_threshold = 0.01,
  use_normalized_intensities = FALSE,
  use_irt = TRUE,
  return_decoys = FALSE,
  remove_shared_spectronaut_proteingroups = FALSE,
  do_plot = TRUE
)


# change to overwrite / append
dataset <- import_fasta(
  dataset,
  files = fastafiles
)

# optional protein removal
##### Placeholder for adding this step

# create a template file to describe your sample metadata
write_template_for_sample_metadata(dataset, "samples.xlsx", overwrite = FALSE)
