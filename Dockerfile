FROM python:3.7.1

COPY ["requirements.txt", "requirements.txt"]
RUN ["pip", "install", "-r", "requirements.txt"]




ENV PYTHONPATH $PYTHONPATH:/opt
ENV RACK_ENVIRON debug

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]

CMD ["python", "main.py"]
