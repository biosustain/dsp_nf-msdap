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


library(msdap)
print("loaded msdap")

#library(ggplot2)
#print("loaded ggplot")

library(plotly)
print("loaded plotly")

library(listviewer)
print("loaded listviewer")

load("dataset.RData")
print("loaded dataset")


# DIA confidence score distributions

# this data oblect does not include other plots than ggplot_cscore_histograms

step01 <- dataset$plots
step02 <- step01$ggplot_cscore_histograms

for (i in seq_along(ggplot_cscore_histograms)){
    step03 <- step02[[i]]
    step04 <- step03$plot_env
    step05 <- step04$p
    step06 <- ggplotly(step05)
    step07 <- plotly_json(step06, FALSE)
    htmlwidgets::saveWidget(step06, "figure_c_", i, ".html")
    write(step07, 'plot_c_', i, '.json')
}