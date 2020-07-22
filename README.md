# Needed
To follow this readme you only need to install docker and docker-compose. An IDE is optional.


Install docker
Install docker-compose https://docs.docker.com/compose/install/

# Overview

## Best practices
One practice that will help reduce the likely hood that private information gets compromised is to
NEVER write any secret or credential down anywhere that could be synced to any cloud service. This
includes GIT, Docker, Google Drive, Dropbox, or others. Instead, you should store secrets in your
chosen cloud service providers secrets manager. To access those secrets you will need a set of
credentials that should be stored in your cloud providers CLI's default location on your local
machine, or another location that you are certain will never be synced to a remote service. `~/.aws/credentials`
is an example of such a location on a linux machine using the AWS CLI.

## Docker

### COMMON MISTAKES

#### Secrets
Do NOT hard code any secrets in a dockerfile or any other file in ANY git repo. The best practice
is to use a secret management solution (AWS secrets, GCP secrets, Azure key-vault) and set those
values to environment variables in the ENTRYPOINT. This ensures if your docker container gets
released to the public no one can access anything private.


#### Credentials (AWS, Azure, GCP, ect...)
Do NOT include your IAM or other credentials in your container! This includes hard
coding them in a .env file, config file, Dockerfile, or any other file that is included in your docker
build. The correct way to pass credentials to a container is through run time variables. This is
how hosting services do it. For example: If you are running a docker container using AWS docker service
(ECS) AWS will pass the IAM (AWS username and password) into the running container via environment
variables that do NOT persist over restarts [0].

To do this yourself use `docker run -e <key>=<value> ...` This is explained in more depth in the
docker run section of the README.

[0] This is not 100% accurate. AWS tricks you into thinking the IAM creds are Env Vars,
but it is actually making an API call, however your code can't tell the difference.

### Basics

Docker concepts can be described in terms of VMs and OSs. A docker `image` can be thought of as the OS that
runs in a VM (`contianer`). You choose the OS, install everything you need and run your code in it.
The docker runtime is analogues to the VM program (VMWare or other).

#### Phases
Docker has two main phases, building a docker container, and running the docker container. You can
also Push a docker container to a remote docker repo to run on a hosted VM.

The two main ways you execute the docker run and build phases are using either the normal docker
runtime via the CLI: `docker build ...`, `docker run ...` or using the docker-compose
utility. See the docker-compose section for more details.

##### Build
During the `build` phase the docker runtime parses your Dockerfile, creates layers based on the steps
contained within, executes the steps, and saves the resulting container.

In practice this means if any changes are made to files or configurations that are put into a build layer
you must rebuild the container for those changes to take effect.

NOTE: The major exception to this is when copying your source files over to the docker container
(`ADD . /opt` in the example Dockerfile) if you are mounting your source code as a volume during
`docker run` (`docker run -v /$PWD:/opt` in the `start_locally.sh` example script) any code changes
you make will be reflected in the container immediately upon saving. You will not even have to restart
the running container.

**A common build command is:**
`docker build -t local:example .`

`-t` Name and optionally a tag in the ‘name:tag’ format.

`local:example` is the `name:tag`

`.` is telling docker to use the "Dockerfile" in the current directory. This could be a path to any
directory. `~/example_project/Dockerfile` for example.

##### Run

`docker run` sends the built docker container (image) to the docker runtime. The runtime loads the layers
that were built and executes the `ENTRYPOINT` and `CMD` clauses in your dockerfile. You can overwrite
those at runtime like so
`docker run <optional --entrypoint [new command]> <other flags/arguments> [docker_image_name] <optional overide for CMD">`

**A common run command is:**
`docker run -i -t example:local /bin/bash`

`/bin/bash` is the CMD override.

`-i` tells keep STDIN open even if not attached

`-t` allocates a pseudo-tty

`-i -t` combined make it to where you can treat a running docker container almost exactly as you
would your code running locally or your local bash client, but still be running it in a constant
environment, mostly, isolated from your system.


##### Push

#### Dockerfile
This is one of the most important pieces of docker. It is the blueprint that all images and containers
are built. A dockerfile must contain some basic pieces.

##### FROM clause
This is the "OS" (more accurately describes an environment or `base image`) that you will install stuff on
top of and eventually run your code in. This does not have to be a bear bones linux distribution (OS)
(Debian, Ubuntu ect...) but can be something built on top of one.
In this project the python image is being used. In reality the python image is just Debian with some
libraries/packages installed on top of it to enable python run out of the box.

The best way to select the `base image` you want to use is to go to [DockerHub](https://hub.docker.com/)
and search for the language, framework, db, or other that you will be using.
These base images are usually ["Docker Official Images"](https://docs.docker.com/docker-hub/official_images/)
and will "Just Work"TM.

##### ENTRYPOINT clause
ENTRYPOINT is one of two main clauses that are executed during the `docker run` phase. ENTRYPOINT
gives specifies a command that is executed just before the `CMD` clause.

ENTRYPOINT is frequently used to finish setting up the environment. This can involve setting
environment variables containing secrets whether they be DB secrets, encryption keys, or something
else you do not want the entire world to know.

##### CMD clause


#### Image


#### Container

#### Docker runtime

#### docker-compose
docker-compose uses an additional YAML file to help streamline spinning up, linking, and tearing
down one (or many) docker containers. It is used to replace (wrap) the more "normal" `docker run...`
and `docker build ...` steps to make a more streamlined experience.

[Here](https://docs.docker.com/compose/) is a link to the official docker-compose docs.

Even though docker-compose uses a separate YAML file you still need to have written a Dockerfile
that you reference in the docker-compose.yaml.

## pip-tools

## Testing

## General Python


### Versions
PEP 440

Version regex:
`N[.N]+[{a|b|c|rc}N][.postN][.devN]`

### Code Style
PEP 8
* Use 4 spaces per indentation level
* Lines <= 79 caracters
* Encode files with UTF-8 (or ASCII but just use utf-8...)
* Names:
    * Class Name `CamelCase`
    * Exception names end with `Error`
    * Function names `lowercase_with_underscores`
    * Private Attributes or methods '_underscore_before_name'

#### Auto PEP 8
```
pip install pep8
pep8 file_name.py
```


### Auto error checking
* pyflakes
* pylint
* flake8 (pyflakes+pep8)

### IDEs
Pycharm

