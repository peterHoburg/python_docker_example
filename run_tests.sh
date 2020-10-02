#!/usr/bin/env bash

# Here is an example of how to run tests using docker build/run
# TODO set dev env vars
docker build -t local:example .
echo "Running MyPy"
docker run -v /$PWD:/opt -it local:example mypy /opt
echo "Running pytest"
docker run -v /$PWD:/opt -it local:example pytest

# You could also run tests using docker-compose. This builds the test container, attaches a postgres
#   container to it , runs the test container, and tears everything down.
docker-compose up test
docker-compose down
