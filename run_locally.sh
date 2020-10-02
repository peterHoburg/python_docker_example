#!/usr/bin/env bash

# local:example is the name:tag of the image being built. It could be anything as long as the
#   corresponding name:tag is passed to the docker run command.
docker build --build-arg DEV=true -t local:example .
docker run -v /$PWD:/opt -i -t local:example
