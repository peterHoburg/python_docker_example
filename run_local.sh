#!/usr/bin/env bash

docker build -t local:example .
docker run -v /$PWD:/opt -it local:example /bin/bash