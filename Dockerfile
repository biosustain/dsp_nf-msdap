################################################################################
FROM rocker/verse:4.3.1
LABEL MAINTAINER="github.com/biosustain/dsp_nf-msdap"


### system dependencies
# libpoppler is a pdftools requirement
# libnetcdf is required downstream by R package ncdf4, which is an upstream dependency
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  libnetcdf-dev \
  libfontconfig1-dev \
  netcdf-bin \
  libpoppler-cpp-dev \
  libcurl4-gnutls-dev \
  git \
  cmake

RUN R -e "install.packages(c('devtools', 'tidyverse', 'tinytex', 'BiocManager'), repos='https://cloud.r-project.org')"
RUN R - e "tinytex::install_tinytex()"
# On Windows; say 'no' to optionally compile packages and during TinyTex installation you may see 2 popups; these can be dismissed
RUN R -e "BiocManager::install(c('ProtGenerics', 'MSnbase', 'limma'), update=T, ask=F)"
RUN R -e "Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS='true')"
RUN R -e "devtools::install_github('ftwkoopmans/msdap', upgrade = 'never')"

RUN echo "Done"