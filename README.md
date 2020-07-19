# Needed
Install docker

Install docker-compose https://docs.docker.com/compose/install/

# python_docker_example

## Versions
PEP 440

Version regex:
`N[.N]+[{a|b|c|rc}N][.postN][.devN]`

## Code Style
PEP 8
* Use 4 spaces per indentation level
* Lines <= 79 caracters
* Encode files with UTF-8 (or ASCII but just use utf-8...)
* Names:
    * Class Name `CamelCase`
    * Exception names end with `Error`
    * Function names `lowercase_with_underscores`
    * Private Attributes or methods '_underscore_before_name'

### Auto PEP 8
```
pip install pep8
pep8 file_name.py
```


## Auto error checking
* pyflakes
* pylint
* flake8 (pyflakes+pep8)
