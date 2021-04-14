FROM r-base:4.0.4

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  libxml2-dev \
  libcurl4-openssl-dev \
  libfontconfig1-dev \
  libssl-dev \
  libsodium-dev \
  curl \
  sqlite3

RUN R -e "install.packages('plumber')"
RUN R -e "install.packages('RSQLite')"
RUN R -e "install.packages('data.table')"
RUN R -e "install.packages('jsonlite')"
RUN R -e "install.packages('R6')"

COPY ./pkg/rctrandr_0.0.1.tar.gz /home/ruser/rctrandr_0.0.1.tar.gz
RUN R -e "install.packages('/home/ruser/rctrandr_0.0.1.tar.gz', repos = NULL, type='source')"

# do we need to define a custom user rather than running as root?
# RUN useradd ruser \
#	&& mkdir /home/ruser \
#	&& chown ruser:ruser /home/ruser 

RUN mkdir -p /home/ruser/randr

ADD ./R/serve.R /home/ruser/randr/serve.R
ADD ./R/api.R /home/ruser/randr/api.R
ADD ./R/model.R /home/ruser/randr/model.R
ADD ./R/version.R /home/ruser/randr/version.R
# ADD ./R/model.rds /home/ruser/randr/model.rds

EXPOSE 8000
WORKDIR /home/ruser/randr
ENTRYPOINT ["Rscript", "serve.R"]

