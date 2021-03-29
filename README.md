# randr

Containerised REST API proof of concept demo providing interface to R randomisation package, see [rctrandr](https://github.com/jatotterdell/rctrandr).


# Getting started

Built under unbuntu 20.04 using Docker version 20.10.5, build 55c4c88.
 
Pre-requisites are `docker`. 
If nececssary, see [Docker notes](https://github.com/maj-biostat/misc-notes/blob/master/docker.md).

Clone repository to local directory and build.

```sh
$ git clone https://github.com/adaptivehealthintelligence/randr.git
$ cd randr; pwd
/home/user/randr
$ docker build -t randr .
$ docker images
REPOSITORY        TAG       IMAGE ID       CREATED          SIZE
randr             latest    37e38ac1d232   16 minutes ago   1.05GB
```

Create directory on local machine as permanent volume.

```sh
$ mkdir -p /data/randr/
```

Launch container

```sh
$ docker run -it -v /data/randr:/share -p 8000:8000 --rm randr
Running plumber API at http://0.0.0.0:8000
Running swagger Docs at http://127.0.0.1:8000/__docs__/
```

(or run in detached mode with `-d`).

To test, open browser and navigate to swagger:

![Swagger](https://github.com/adaptivehealthintelligence/randr/fig/swagger.png)

Or `curl`

```sh
curl -X GET "http://127.0.0.1:8000/completerand?numbertrt=3&samplesize=6" -H "accept: application/json"
```


