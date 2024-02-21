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

RUN R -e "tinytex::tlmgr_install(c('ifxetex', 'ifluatex', 'oberdiek', 'graphics', 'graphics-cfg', 'graphics-def', 'amsmath', 'latex-amsmath-dev', 'euenc', 'fontspec', 'tipa', 'unicode-math', 'xunicode', 'ltxcmds', 'kvsetkeys', 'etoolbox', 'xcolor', 'geometry', 'fancyvrb', 'framed', 'bigintcalc', 'bitset', 'etexcmds', 'gettitlestring', 'hycolor', 'hyperref', 'intcalc', 'kvdefinekeys', 'letltxmacro', 'pdfescape', 'refcount', 'rerunfilecheck', 'stringenc', 'uniquecounter', 'zapfding'))"

# CRAN R packages we need that aren't in this rocker/verse
RUN R -e "install.packages(c('archive', 'styler', 'formatR', 'pdftools', 'matrixStats', 'lme4', 'nloptr', 'pROC', 'iq', 'doParallel', 'foreach', 'missForest', 'ggpubr', 'ggrepel', 'patchwork', 'openxlsx'), repos = 'https://cloud.r-project.org')"

# BioConductor R packages
RUN R -e "BiocManager::install(c('ProtGenerics', 'MSnbase', 'limma', 'vsn', 'pcaMethods', 'DEqMS', 'BiocParallel', 'variancePartition', 'argparse'), update=F, ask=F)"

# GitHub R packages
RUN R -e "devtools::install_github('zimmerlab/MS-EmpiRe', upgrade = 'never')"
RUN R -e "devtools::install_github('vdemichev/diann-rpackage', upgrade = 'never')"

# 'variancePartition' package now requires 'remaCor' package version >= 0.0.11
RUN R -e "devtools::install_version('remaCor', '0.0.16', upgrade = 'never', \
repos = 'https://cloud.r-project.org')"

### MS-DAP
# From github
RUN R -e "devtools::install_github('ftwkoopmans/msdap', upgrade = 'never')"

RUN chmod 777 /home

RUN echo "Done"