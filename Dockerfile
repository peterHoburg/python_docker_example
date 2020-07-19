# Python 3.8 UPDATED ON 07-17-2020
FROM python@sha256:99307ba08435e9c7cddf3889ad2b2aec24c95272531c3db9ee6ff8939aea288c

WORKDIR /opt
ENV PYTHONPATH $PYTHONPATH:/opt

COPY ["requirements.txt", "requirements.txt"]
RUN ["pip", "install", "-r", "requirements.txt"]

ADD . /opt
# TODO pass build arg to bash script or env var?
ARG ENVIRONMENT
ARG DEBUG
ARG DEV

ENV ENVIRONMENT local
ENV DEBUG false
ENV DEV false

RUN bash install_dev_requirements.sh

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]

CMD ["python", "main.py"]
