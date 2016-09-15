FROM nimbix/ubuntu-desktop:trusty
MAINTAINER Nimbix, Inc

RUN apt-get update && apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:openscad/releases
RUN apt-get update && apt-get install -y openscad

RUN apt-get clean && rm -rf /var/lib/apt/*
