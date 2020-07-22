# Setup
To follow this readme and run this project you only need to install docker and docker-compose.
An IDE is optional.

[Installing docker](https://docs.docker.com/get-docker/)

[Installing docker-compose](https://docs.docker.com/compose/install/)

# General Best practices
Here are some best practices that can be applied to more than just python or docker

## Secrets management
NEVER write any secret or credential down anywhere that could be synced to any cloud service. This
includes GIT, Docker, Google Drive, Dropbox, or others.

Instead, you should store secrets in your chosen cloud service providers secrets manager. To access
those secrets you will need a set of credentials. Those should be stored in your cloud providers
CLI's default location on your local machine, or another location that you are certain will never
be synced to a remote service. `~/.aws/credentials` is an example of such a location on a linux
machine using the AWS CLI.

Alternatively you can store some secrets in a .env file that is loaded automatically into your environment
when running code. CAUTION: When using a .env file you MUST add it to your .dockerignore and .gitignore
files and any other ignore list for software that may accidentally sync it to a remote server.

For more docker specific examples and an explanation on how I manage secrets in this python example
project see [here](#pip-tools).

# Docker
This is a short overview that focuses on some of the most widely used pieces of docker. This is not
a comprehensive docker guide, but rather a guide on what I think the

## COMMON MISTAKES

### Secrets
Do NOT hard code any secrets in a dockerfile or any other file in ANY git repo. The best practice
is to use a secret management solution (AWS secrets, GCP secrets, Azure key-vault) and set those
values to environment variables in the ENTRYPOINT. This ensures if your docker container gets
released to the public no one can access anything private.


### Credentials (AWS, Azure, GCP, ect...)
Do NOT include your IAM or other credentials in your container! This includes hard
coding them in a .env file, config file, Dockerfile, or any other file that is included in your docker
build. The correct way to pass credentials to a container is through run time variables. This is
how hosting services do it. For example: If you are running a docker container using AWS docker service
(ECS) AWS will pass the IAM (AWS username and password) into the running container via environment
variables that do NOT persist over restarts[^fn0].

To do this yourself use `docker run -e <key>=<value> ...` This is explained in more depth in the
docker run section of the README.

[^fn0]: This is not 100% accurate. AWS tricks you into thinking the IAM creds are Env Vars,
but it is actually making an API call, however your code can't tell the difference.

## Basics

Docker concepts can be described in terms of VMs and OSs. A docker `image` can be thought of as the OS that
runs in a VM (`contianer`). You choose the OS, install everything you need and run your code in it.
The docker runtime is analogues to the VM program (VMWare or other).

### Phases
Docker has two main phases, building a docker container, and running the docker container. You can
also Push a docker container to a remote docker repo to run on a hosted VM.

The two main ways you execute the docker run and build phases are using either the normal docker
runtime via the CLI: `docker build ...`, `docker run ...` or using the docker-compose
utility. See the docker-compose section for more details.

#### Build
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

#### Run

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


#### Push
docker push is very similar to git push. After building a docker container locally you "push" it to
a remote docker store; either privately hosted on a cloud provider, or the docker hub public store if you
want your container publicly available.

Each store has slightly different ways of authenticating before pushing. Please reference the relevant
docs.

### Dockerfile
This is one of the most important pieces of any dockerized project. It is the blueprint that all
of your images and containers are built from. A dockerfile must contain some basic pieces; FROM,
ENTRYPOINT, and CMD. Entrypoint can be excluded, but is almost always uses.

#### Syntax overview
Each line start with a keyword. Common ones are `FROM, WORKDIR, ENV, COPY, RUN, ARG, ADD, ENTRYPOINT, CMD`.
Following the keyword you either plain strings or JSON lists telling the keyword what to do. Many of
the keywords work with both JSON array syntax (exec form) and the shell form. Example:

`CMD ["python", "main.py"]` JSON array AKA exec form. This is the preferred form for commands that support it.

NOTE: The exec form uses double quotes " not single '

`CMD python main.py` shell form.

#### FROM clause
This is the "OS" (more accurately describes an environment or `base image`) that you will install stuff on
top of and eventually run your code in. This does not have to be a bear bones linux distribution (OS)
(Debian, Ubuntu ect...) but can be something built on top of one.
In this project the python image is being used. In reality the python image is just Debian with some
libraries/packages installed on top of it to enable python run out of the box.

The best way to select the `base image` you want to use is to go to [DockerHub](https://hub.docker.com/)
and search for the language, framework, db, or other that you will be using.
These base images are usually ["Docker Official Images"](https://docs.docker.com/docker-hub/official_images/)
and will "Just Work"TM.

#### ENTRYPOINT clause
ENTRYPOINT is one of two main clauses that are executed during the `docker run` phase. ENTRYPOINT
gives specifies a command that is executed just before the `CMD` clause.

ENTRYPOINT is frequently used to finish setting up the environment. This can involve setting
environment variables containing secrets whether they be DB secrets, encryption keys, or something
else you do not want the entire world to know.

#### CMD clause
[Docs](https://docs.docker.com/engine/reference/builder/#cmd)


This is where you finally get to run your code! The CMD clause is the last thing docker executes, and
is used to run your project. The Dockerfile CMD can be overwritten in `docker run` phase, see docker
run section for more details.

A normal use would be: `CMD ["python", "main.py"]` This tells docker you want to have the python
runtime execute your main.py file.

### Image


### Container

### Docker runtime

### docker-compose
docker-compose uses an additional YAML file to help streamline spinning up, linking, and tearing
down one (or many) docker containers. It is used to replace (wrap) the more "normal" `docker run...`
and `docker build ...` steps to make a more streamlined experience.

[Here](https://docs.docker.com/compose/) is a link to the official docker-compose docs.

Even though docker-compose uses a separate YAML file you still need to have written a Dockerfile
that you reference in the docker-compose.yaml.

# pip-tools
pip-tools is made up of 2 main parts. pip-compile and pip-sync. We will not be using pip-sync in
this example project.

## pip-compile
[Docs](https://github.com/jazzband/pip-tools)

pip-compile is one of the main tools that we are using to enable reproducible builds in python. When using normal
pip to install a library, even if you specify what version of the lib you want to install, you are
not guarantied to install the same packages every time you run `pip install pandas`. In this example
`pandas` has other packages it depends on, one of them being `python-dateutil >= 2.7.3`. This means that
depending on what the latest version of `python-dateutil` is when you install pandas you might get 2.7.3 or 2.8.
This can lead to very subtle bugs being introduced even when no code changes have been made.

To solve this pip-compile gets every dependency of every package recursively and adds an exact version
of  them to your requirements.txt file. In addition to just a version number you can tell pip-tools
to write the hash of the package to the requirements.txt file, this not only ensures you are getting
the exact package every time, but can also add a layer of security.

### Use
pip-compile takes your project requirements, written in a `requirements.in` file, and outputs the compiled
deps into a `requirements.txt` file that you then tell pip to install from.

NOTE: You can have more than one requirements file.

For example if you need to use `ipdb` or `pytest` when developing you can make a
`requirements-dev.in/txt` and link it to your main `requirements.txt` file.
This is what is being done in this project. You simply add `-c requirements.txt` at the start of your
dependent `requirements-dev.in` file and pip-compile will take into account the dependencies in
your main `requiremetns.txt` file.

This is the command you run to compile, or update, all of your dependencies from the `.in` to `.txt` file.

`pip-compile --rebuild --upgrade --generate-hashes --allow-unsafe requirements.in`

`--rebuild` this forces pip-compile to rebuild the pip cache and check pypi before compiling.

`--upgrade` this tells pip-compile to update all dependencies to the latest version.

`--generate-hashes` this tells pip-compile to generate hashes for each lib

`--allow-unsafe` this lets pip-compile add a setuptools and pip version to the .txt file. This is
generally not considered a best practice, but also helps ensures that the pip install will be the same
every time.

`requirements.in` the file name to create the compiled `.txt` file from.

NOTE: This command is commented out at the bottom of the requirements.in file for your convince.

# Testing
Testing in python is extremely important and relatively easy! Python has a good built in testing
library called `unittest` and a very good community library called `pytest` that is built on
`unittest` and can run all unittest tests but includes many extra amazing features. There is also
a library called `nose` that I do not recommend using unless you are already familiar with it. There
is nothing wrong with `nose` I just find it harder to use compared to pytest or unittest.

In addition to the main testing library `hypothesis` is an amazing library that adds amazing features
to your chosen main testing library. `hypothesis` works best with pytest, but will work well with other
libs. Please check out [hypothesis'](https://hypothesis.readthedocs.io/en/latest/) docs for more information.

Python is a dynamically typed language and as such type conversion or mismatching bugs can sneak in,
fortunately there are some good libraries designed to help with exactly this issue. The most common
one being `mypy`. [Here](https://mypy.readthedocs.io/en/stable/) are the docs. Running mypy as a pre
merge or commit git script can help catch bugs before they hit production.


## Books
[TDD with python](https://www.obeythetestinggoat.com/)

# General Python
Here are some general python standards

## Versions
[PEP 440](https://www.python.org/dev/peps/pep-0440/) specifies how version should be defined in python.

The following is the regex that generally defines valid python version:
`N[.N]+[{a|b|c|rc}N][.postN][.devN]`

## Code Style
Code style is extremely important in python. Fortunatly [PEP 8](https://www.python.org/dev/peps/pep-0008/)
contains most of the python best practices. Here are some of the main ones:


* Use 4 spaces per indentation level. Don't use tabs.
* Lines <= 79 characters
* Encode files with UTF-8 (or ASCII but just use utf-8...)
* Names:
    * Class Name `CamelCase`
    * Exception names end with `Error`
    * Function names `lowercase_with_underscores`
    * Private Attributes or methods '_underscore_before_name'


To help enforce the PEP 8 standard there are numerous libs that will automatically check your code. Some
well-known ones are :

* pyflakes
* pylint
* autopep8
* flake8 (pyflakes+pep8)

There are many more with different advantages.


## IDEs
Pycharm
VScode
VIM

