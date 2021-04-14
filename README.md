# randr

Containerised REST API proof of concept demo providing interface to R randomisation package, see [rctrandr](https://github.com/jatotterdell/rctrandr).

# Getting started

Built under unbuntu 20.04 using Docker version 20.10.5, build 55c4c88.
 
Pre-requisites are `docker` and git. 
See [Docker notes](https://github.com/maj-biostat/misc-notes/blob/master/docker.md) if necessary.

Clone repository to local directory

```sh
$ git clone https://github.com/adaptivehealthintelligence/randr.git
$ cd randr
```

Define the model to be used in the tool.
This is performed interactively in R by the `version.R` script into the `/data` directory.
Alternatively, if running for first time can use

```sh
$ cd R
$ Rscript version.R
$ cd ..
```

Build the container

```sh
$ docker-compose build
```

Launch the container

```sh
$ docker-compose up
randr_1  | Running plumber API at http://0.0.0.0:8000
randr_1  | Running swagger Docs at http://127.0.0.1:8000/__docs__/
```

and ctrl-clink on the link to open in browser and test endpoints.

![Swagger](swagger.png?raw=true "Swagger UI")

