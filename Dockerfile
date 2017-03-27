FROM python:3.6
MAINTAINER Michaël Perrin <mperrin@greenflex.com>

# RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm get-pip.py

RUN apt-get update \
    && apt-get install -y \
        texlive-latex-extra

RUN pip install sphinx~=1.5.3 git+https://github.com/michaelperrin/sphinx-php

WORKDIR /var/www/symfony-docs/_build

# docker build -t sf_sphinx .
# docker run --rm -d -v `pwd`:/var/www/symfony-docs --name symfony_docs_generator sf_sphinx "make html"
