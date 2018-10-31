FROM python:3.7.1

COPY ["requirements.txt", "requirements.txt"]
RUN ["pip", "install", "-r", "requirements.txt"]


ADD . /opt
WORKDIR /opt

ENV PYTHONPATH $PYTHONPATH:/opt

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]

CMD ["python", "main.py"]
