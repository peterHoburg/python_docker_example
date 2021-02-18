#!/usr/bin/env bash
docker_container_name="example:local"

docker build --build-arg DEV=true -t $docker_container_name .

docker run \
-v /$PWD:/opt \
-i \
-t $docker_container_name /bin/bash
