FROM ftwkoopmans/msdap:1.0.7
LABEL MAINTAINER="github.com/biosustain/dsp_nf-msdap"

# for nextflow pipeline
RUN R -e "install.packages(c('argparse', 'plotly', 'listviewer', 'pheatmap', 'htmlwidgets'), repos = 'https://cloud.r-project.org')"

# remove package to make sure to fail process if "update" fails
RUN R -e "remove.packages('msdap')"
# "upgrade" msdap plugin to custom fork
RUN R -e "devtools::install_github('biosustain/msdap@development', upgrade = 'never')"

# for azure batch processing
RUN chmod -R 777 /home

