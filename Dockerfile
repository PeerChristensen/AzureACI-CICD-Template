FROM rocker/r-ver:4

## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
libxml2-dev \
libcairo2-dev \
libsqlite3-dev \
libmariadbd-dev \
libpq-dev \
libssh2-1-dev \
unixodbc-dev \
libcurl4-openssl-dev \
libssl-dev

## copy files
#COPY .Renviron /.Renviron
COPY script.r /script.r

## install packages with command
RUN R -e "install.packages(c('httpuv','AzureStor', 'dplyr', 'readr', 'AzureKeyVault'))"


## install packages with R-script
#COPY install_packages.r /tmp/install_packages.r
#RUN Rscript /tmp/install_packages.r


CMD R -e "source('/script.r')"