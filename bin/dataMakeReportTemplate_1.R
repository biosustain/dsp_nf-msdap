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
format <- arg[2]

library(msdap)

if (tolower(format) == "spectronaut") {
  dataset <- import_dataset_spectronaut(
    filename = filenamepath,
    confidence_threshold = 0.01,
    use_normalized_intensities = FALSE,
    use_irt = TRUE,
    return_decoys = FALSE,
    remove_shared_spectronaut_proteingroups = FALSE,
    do_plot = TRUE
  )
} else {
  print(format)
}

# create a template file to describe your sample metadata
write_template_for_sample_metadata(dataset, "samples.xlsx", overwrite = FALSE)
