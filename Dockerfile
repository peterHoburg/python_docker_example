
# Spedifing the sha256 hash of your FROM image ensures that all of the conatiners you build
#   weather locally or in a CI or on another devs machine will always have the same base

# NOTE: REMEMBER TO UPDATE THIS CONTAINER!! Run "docker pull python:3.8" and copy the hash that is
#   printed after the container finishes downloading
# Python 3.8 UPDATED ON 07-17-2020
FROM python@sha256:e9b7e3b4e9569808066c5901b8a9ad315a9f14ae8d3949ece22ae339fff2cad0

WORKDIR /opt
ENV PYTHONPATH $PYTHONPATH:/opt

COPY ["./requirements/requirements.txt", "./requirements/requirements.txt"]
RUN pip --use-feature=2020-resolver install -r ./requirements/requirements.txt

# These are only availiable during a docker build to have them persist into a docker run use ENV
ARG ENVIRONMENT=local
ARG DEBUG=false
ARG DEV=false

# These can not be set in a docker build. Using the -e in a docker run will change these during runtime
ENV ENVIRONMENT="${ENVIRONMENT}"
ENV DEBUG="${DEBUG}"
ENV DEV="${DEV}"

# This allows you to install dev dependencies in a docker layer negating the need to install them
#   every time a container is run.
# WARNING: This script uses the ARG/ENV DEV value to decide if the requirements-dev.txt should be installed
COPY ["./requirements/requirements.txt", "./requirements/requirements.txt"]
COPY ["./requirements/install_dev_requirements.sh", "./requirements/install_dev_requirements.sh"]
RUN bash ./requirements/install_dev_requirements.sh
RUN pip check

# Always have this as far down as you can. If anything being coppied in this step changes all steps
#   run after it will be rerun instead of using existing container layers.
ADD . /opt

# This is executed during docker run. This is a good place to set DB and other secrets to env vars
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]

# This is the last thing docker runs. You can overwrite it like so:
#   docker run -it <docker_container_name:tag> <command_to_run IE /bin/bash>
CMD ["python", "python_docker_example/main.py"]
