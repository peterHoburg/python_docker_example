#!/usr/bin/env bash

docker build -t local:example .
docker run -v /$PWD:/opt -i -t local:example