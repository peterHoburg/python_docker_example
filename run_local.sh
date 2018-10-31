#!/usr/bin/env bash

docker build -t local:example .
docker run -v /$PWD:/opt -it local:example

# If you want to start an interactive terminal in the docker container instead of executing the CMD command in the
#   Dockerfile use the following command instead of the above run command.

# docker run -v /$PWD:/opt -it local:example /bin/bash