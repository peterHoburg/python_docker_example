#!/usr/bin/env bash

docker build --build-arg DEV=true -t local:example .
docker run -v /$PWD:/opt -i -t local:example /bin/bash
