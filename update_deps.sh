: > ./requirements/requirements.txt
: > ./requirements/requirements-dev.txt
chmod 777 ./requirements/requirements.txt
chmod 777 ./requirements/requirements-dev.txt
docker build -t local:update_deps .
docker run -v /$PWD:/opt -it local:update_deps /bin/bash /opt/requirements/install_and_freeze.sh
