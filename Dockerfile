# Python 3.7 UPDATED ON April 17/2019
FROM python@sha256:ef316cc13b7578f8aae023ab6ba538520f2cf618ed4d239c63925a9fccbe254b

COPY ["requirements.txt", "requirements.txt"]
RUN ["pip", "install", "-r", "requirements.txt"]

ADD . /opt
WORKDIR /opt


ENV PYTHONPATH $PYTHONPATH:/opt
ENV RACK_ENVIRON debug

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]

CMD ["python", "main.py"]
