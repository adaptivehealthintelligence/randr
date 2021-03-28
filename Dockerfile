FROM r-base:4.0.4
MAINTAINER maj maj@email.com

RUN useradd ruser \
	&& mkdir /home/ruser \
	&& chown ruser:ruser /home/ruser 

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  libxml2-dev \
  libcurl4-openssl-dev \
  libfontconfig1-dev \
  libssl-dev \
  libsodium-dev  \
  netcat && which nc
#  libharfbuzz-dev \
#  libfribidi-dev

# how to get specific versions?
RUN R -e "install.packages('devtools',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('plumber',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('data.table', dependencies=TRUE, repos='http://cran.rstudio.com/')"

# RUN R -e "devtools::install_github('maj-biostat/rctrandr')"
COPY rctrandr_0.0.1.tar.gz /home/ruser/rctrandr_0.0.1.tar.gz
RUN R -e "install.packages('/home/ruser/rctrandr_0.0.1.tar.gz', repos = NULL, type='source')"

RUN mkdir /home/ruser/randr
ADD R/plumber.R /home/ruser/randr/plumber.R
ADD R/funcs.R /home/ruser/randr/funcs.R

RUN apt-get update && apt-get install -y curl

EXPOSE 8000
WORKDIR /home/ruser/randr
# CMD ["/usr/bin/Rscript", "/home/ruser/randr/plumber.R"]

ENTRYPOINT ["R", "-f", "plumber.R", "--slave"]

