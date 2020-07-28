# Setup
To follow this readme and run this project, first install docker and docker-compose.
Please note that an IDE is optional.

[Installing docker](https://docs.docker.com/get-docker/)

[Installing docker-compose](https://docs.docker.com/compose/install/)

# General Best practices
The best practices outlined in this documentation can be applied to more than Docker and Docker-compose.

## Secrets management
When deciding where to store secrets or credentials, the first consideration should be whether the information will be synced to a cloud service. Common services which would sync information to the cloud
include GIT, Docker, Google Drive, and Dropbox.

A preferable option instead would be to utilize your cloud service's secrets manager, as secrets managers require a second set of credentials for access. Those credentials, then, could be stored in your cloud provider's
CLI's default location on your local machine or another location which you are certain will never
be synced to a remote service. `~/.aws/credentials` is an example of such a location on a Linux
machine using the AWS CLI. ***REWRITE THIS SENTENCE****

Alternatively, you could store some secrets in a .env file which is then loaded automatically into your environment
while executing code. When using this method, a note of caution: using a .env file requires that you add the file to .dockerignore and .gitignore
files and other ignore lists to ensure that no software unintentionally syncs it to a remote server.

***REWRITE THIS SENTENCE*** A full example of instantiated best practices in Python and also other Docker-specific examples are available [here](#common-mistakes).

# Docker

The following information is a short overview focusing on widely used aspects of Docker. This information is not intended as a comprehensive Docker guide and should not be used as such. A more comprehensive exploration into Docker can be found by [reading the docs](https://docs.docker.com/)

## Common Mistakes

### Secrets
As always, the best practice is for users to never hard code secrets in a file which may be released to the public for any reason. For example, secrets should never be stored in a dockerfile or any file in a git repo. Within Docker, the best practice
is to use a secret management solution (AWS secrets, GCP secrets, Azure key-vault) and set those
values to environment variables in the ENTRYPOINT. This ensures if your docker image gets
released to the public no one can access anything private.

### Credentials (AWS, Azure, GCP, ect...)
Do NOT include your IAM or other credentials in your container! Note that hard coding these credentials in the following file types/locations should be considered as including them in your container:
1. in .env file (that is not included in a .dockerignore),
2. config file,
3. Dockerfile,
4. any other file that is included in your docker build.

The correct way to pass credentials to a container is through runtime variables, and hosting services use this practice. For example: if you
are running a docker container using AWS docker service (ECS), AWS will pass the IAM
(AWS username and password) into the running container via environment variables that do NOT
persist over restarts<sup id="a1">[1](#f1)</sup>.

To complete this process yourself, use `docker run -e <key>=<value> ...` More detailed instructions are available in the
[docker run section](#run) of the README.

## Basics

### Terminology
* Image: the basis of a container. Images do not have state. Public images can be found on the [docker hub](https://hub.docker.com/).
* Container: Runtime instance of an image. Comprised of an image + execution environment + instructions.
* Docker runtime/desktop: the program which runs your container.

For additional terminology, please review the [docker glossary](https://docs.docker.com/glossary/)

### Overview
The core Docker concepts can be described in terms of VMs and OSs. For example, a docker `image` is analogous to
the chosen OS which will run in a VM. A container, then, would be similar to the running OS when the necessary dependencies
have been installed to run your specific code. Finally, the docker runtime is analogous to the VM program itself (VMWare or other).

### Phases
Docker has two main phases: building a docker image and then running a docker container. An additional
option is to push a docker image to a remote docker repository in order to run it on a hosted machine.

These phases are executed via two primary methods: using the normal docker
runtime via the CLI: `docker build ...`, `docker run ...` or using the docker-compose
utility. For more informatoin regarding the docker-compose utility, please review [docker-compose](#docker-compose).

#### Build
During the `build` phase, the docker runtime parses the Dockerfile, creates layers based on the steps
in the Dockerfile, executes the steps (except for the CMD/ENTRYPOINT steps), then saves the
resulting image to disk.

All images are built using a Dockerfile and result in a new image. This new image can then be used in
another Dockerfile, which will result in another new image. Alternately,the generated image can be run as a container.

In practice, users must realize that this process means any changes which are made to files or configurations in the build phase
require a rebuild of the container for those changes to take effect. Once an image is built, it will
not change during the run phase. When a container is restarted, its state will revert back to that of the image being run.

NOTE:

The need to rebuild a container has one major exception: if your source files are mounted to
the Docker container at runtime, you will not need to restart or rebuild the container after source
file changes. Use `-v /$PWD:/opt` as a part of the Docker run command to mount a source directory at runtime.
`start_locally.sh` is an example script that mounts the files at runtime.

**Common build command:**
`docker build -t example:local .`

`-t` Name and optionally a tag in the ‘name:tag’ format.

`example:local` is the `name:tag`

`.` is telling docker to use the "Dockerfile" in the current directory. '.' could also be a path to any
directory. `~/example_project/Dockerfile` is an example.

See [the docker build docs](https://docs.docker.com/engine/reference/commandline/build/) for more information.

#### Run
`docker run` sends a specified image to the Docker runtime, which then creates a container. The runtime loads the layers which
were previously built and executes the `ENTRYPOINT` and `CMD` clauses contained in your dockerfile.
However, you can choose to overwrite those clauses at runtime using
`docker run <optional --entrypoint [new command]> <other flags/arguments> [docker_image_name] <optional overide for CMD">`
In addition to overwriting the entrypoint or cmd clauses, it is common to pass cloud credentials via
environment variables `-e` to the container being run. These credentials can then be used to fetch
secrets from a secrets' manager during the docker container's ENTRYPOINT clause.

**A common run command is:**

`docker run -e VARIABLE_NAME="VALUE" -i -t example:local /bin/bash`

`/bin/bash` is the CMD override.

`-i` keeps STDIN open even if not attached

`-t` allocates a pseudo-tty

`-i -t` when combined, these flags allow for a running docker container to be treated almost exactly as REWRITE THIS
code running locally or your local bash client, but still be running it in a constant
environment, mostly, isolated from your system.


#### Push
Docker push is very similar to git push. After building a Docker image locally, you can "push" it to
a remote Docker store. The remote Docker store can either be privately hosted on a cloud provider or in the Docker hub public store.
Hosting in the public store should be done only if you want your container to be publicly available.

Each store has slightly different ways of authenticating before pushing. Please reference the relevant
docs.

### Dockerfile
A Dockerfile is one of the most important pieces of any Dockerized project, as it is the blueprint from which all
of your images are built and containers run. A Dockerfile generally contain three basic pieces: FROM,
ENTRYPOINT, and CMD. While Entrypoint can be omitted, it is almost always used.

#### Syntax overview
Each line start with a keyword. Common ones are:

`FROM, WORKDIR, ENV, COPY, RUN, ARG, ADD, ENTRYPOINT, CMD`.

Following each keyword, you have either a plain string (shell form), or a JSON list (exec form).
Many keywords accept both exec and shell form. Example uses of the `CMD` keyword:

`CMD ["python", "main.py"]` This is an example of a JSON array (exec form). It is the preferred form for commands which support it.
NOTE: The exec form uses double quotes " not single '

`CMD python main.py` is an example of a plain string, or shell form.

#### FROM clause
A from clause is the `image` which is being built upon. The image can be a barebones Linux distribution (Debian, Ubuntu ect...),
but, more commonly, it is a purpose built image for the framework or lanuage the project will be using.
This project uses the python image. The python image is Debian with some addition components
installed allowing most python code to be run out of the box on it.


A common way to choose the best `image` to build on it is to search [DockerHub](https://hub.docker.com/)
for the language, framework, or db the project will be using. Then select the corresponding
["Docker Official Images"](https://docs.docker.com/docker-hub/official_images/).


#### ENTRYPOINT clause
ENTRYPOINT is one of two main clauses that are executed during the `docker run` phase. The ENTRYPOINT
clause is executed just before the `CMD` clause.

ENTRYPOINT is frequently used to finish setting up the runtime environment. This may involve setting
additional environment variables that containing secrets, encryption keys, or other information
that should not be public.

A typical ENTRYPOINT clause will look like this: `ENTRYPOINT ["/bin/bash", "entrypoint.sh"]`

The previous example is in the exec form and is telling Docker to have bash run the entrypoint.sh script.
`entrypoint.sh` in turn sets environment variables using `export VARIABLE_NAME="<VALUE>"`. `entrypoint.sh`
is a fully fledged bash script and as such can be used to do almost anything. See the entrypoint.sh script
included in this project for more example uses.

NOTE: Anything set during the `docker run` phase will not persist across docker container instances.
Because of the lack of persistence setting secrets in ENTRYPOINT is much safer than setting them
in a build step. Do not hard code secrets in the entrypoint script. The entrypoint script should
call your secrets manager of your choice using the credentials passed to the `docker run` command.

#### CMD clause
[Docs](https://docs.docker.com/engine/reference/builder/#cmd)

The CMD clause is the last clause docker executes. The Dockerfile CMD can be overwritten in the
`docker run` phase, see docker run section for more details.

A normal use of CMD would be: `CMD ["python", "main.py"]` This is  telling docker to use the python
interpreter to execute main.py.

### docker-compose
docker-compose uses an additional YAML file to help streamline spinning up, linking, and tearing
down one (or many) docker containers. docker-compose is especially useful when testing locally using
a temporary database. docker-compose is used to replace the more "normal" `docker run...` and
`docker build ...` commands.

[Here](https://docs.docker.com/compose/) is a link to the official docker-compose docs.

Even though docker-compose uses a separate YAML file you still need to have a Dockerfile.

### Workflow


# pip-tools
pip-tools is made up of 2 main parts. pip-compile and pip-sync. We will not be using pip-sync in
this example project.

## pip-compile
[Docs](https://github.com/jazzband/pip-tools)

pip-compile is one of the main tools that ensure reproducible builds in for python projects.
The main issue faced when attempting to create a reproducible python builts is dependencie management.
Specifically recursive dependence management, AKA the dependencies of the packages you are explicitly
installing. When pip installs a package, even if the version of the package is specified, pip is
not guarantied to install the same packages every time you run, for example, `pip install pandas`. In this example
`pandas` has other packages it depends on, one of them being `python-dateutil` with a version `>= 2.7.3`. This means that
depending on what the latest version of `python-dateutil` is when pandas is installed `python-dateutil`
might be 2.7.3, 2.8, or something else. This can lead to the introduction of very subtle bugs,
 even when there have been no code changes.

pip-compile gets every dependency of every package recursively and adds an exact version
of to requirements.txt. In addition to just a version number pip-compile can write the hash of the
package to the requirements.txt file, this will not only ensure pip installs the correct version of all
 packages every time, but also adds a layer of security.

### Use
pip-compile takes the project requirements, written in a `requirements.in` file, and outputs the compiled
dependencies into a `requirements.txt` file pip then installs from.

NOTE: You can have more than one requirement's file!

For example if `ipdb` or `pytest` are needed during development `requirements-dev.in/txt` files
 can be created and linked the main `requirements.txt` file.
This has been done in this example project. `-c requirements.txt` is placed on the first line of the
`requirements-dev.in` file. When pip-compile is run on the `requirements-dev.in` file pip-compile
will take into account all dependencies specified in the  main `requiremetns.txt` file.

The following is the command used to compile or update all dependencies specified in `.in` file to
the corresponding `.txt` file.

`pip-compile --rebuild --upgrade --generate-hashes --allow-unsafe requirements.in`

`--rebuild` forces pip-compile to rebuild the pip cache and check pypi before compiling.

`--upgrade` tells pip-compile to update all dependencies to the latest version.

`--generate-hashes` tells pip-compile to generate hashes for each package

`--allow-unsafe` lets pip-compile add setuptools and pip versions to the .txt file.

`requirements.in` is the file name to generate the compiled `.txt` file from.

NOTE: This command is commented out at the bottom of the requirements.in file for easy reference.

# Testing
Testing in python is extremely important and relatively easy! Python has a good built in testing
library called `unittest` and a great community library called `pytest`. Pytest is built on top of
`unittest` and can run all tests built using unittest tests, and additionally includes many extra features.
In addition to pytest `nose` can be used to run python tests. I do not recommend using `nose` unless
you are already familiar with it. There is nothing wrong with `nose` I just find pytest more usable.

In addition to the main library being used to run the test cases, `hypothesis` can add to provide some additional amazing features.
`hypothesis` works best with pytest, but will work well with other libraries. Please read the
[hypothesis'](https://hypothesis.readthedocs.io/en/latest/) docs for more information.

Python is a dynamically typed language and as such has the tendencie to have type conversion bugs sneak in.
Fortunately there are many libraries designed to help catch typing issues. The most common
one being `mypy`. See [Here](https://mypy.readthedocs.io/en/stable/) for the mypy docs. Running mypy
as a pre merge or pre commit git hook can help catch bugs before they hit production.


## Books
[TDD with python](https://www.obeythetestinggoat.com/)

# General Python
Here are some general python standards

## Versioning
[PEP 440](https://www.python.org/dev/peps/pep-0440/) specifies how versions should be defined in python.

The following is the regex that defines valid python version:
`N[.N]+[{a|b|c|rc}N][.postN][.devN]`

## Code Style
Code style is extremely important in python. Fortunately [PEP 8](https://www.python.org/dev/peps/pep-0008/)
contains most of the python style best practices. Here are some major ones:

* Use 4 spaces per indentation level. Don't use tabs.
* Lines <= 79 characters
* Encode files with UTF-8 (or ASCII but just use utf-8...)
* Names:
    * Class Name `CamelCase`
    * Exception names end with `Error`
    * Function names `lowercase_with_underscores`
    * Private Attributes or methods '_underscore_before_name'


To help enforce the PEP 8 standard numerous libraries are available that will automatically check your code. Some
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


# Footnotes
<b id="f1">1</b> This is not 100% accurate. AWS tricks you into thinking the IAM creds are Env Vars,
but it is actually making an API call, however your code can't tell the difference.[↩](#a1)
