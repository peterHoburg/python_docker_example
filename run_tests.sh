#!/usr/bin/env bash

docker build -t local:example .
echo "Running MyPy"
docker run -v /$PWD:/opt -it local:example mypy /opt
echo "Running pytest"
docker run -v /$PWD:/opt -it local:example pytest