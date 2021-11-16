#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Image for building and testing Spark branches. Based on Ubuntu 20.04.
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ARG APT_INSTALL="apt-get install --no-install-recommends -y"

RUN apt-get clean
RUN apt-get update
RUN $APT_INSTALL software-properties-common git libxml2-dev pkg-config curl wget openjdk-8-jdk libpython3-dev python3-pip python3-setuptools python3.8 python3.9
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.8
RUN python3.8 -m pip install numpy 'pyarrow<3.0.0' pandas scipy xmlrunner plotly>=4.8 sklearn 'mlflow>=1.0'
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9
RUN python3.9 -m pip install numpy pyarrow pandas scipy xmlrunner plotly>=4.8 sklearn 'mlflow>=1.0'

RUN add-apt-repository ppa:pypy/ppa
RUN apt update
RUN $APT_INSTALL pypy3 gfortran libopenblas-dev liblapack-dev

RUN $APT_INSTALL build-essential pypy3-dev
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | pypy3
RUN pypy3 -m pip install numpy pandas scipy

RUN $APT_INSTALL gnupg ca-certificates pandoc
RUN echo 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' >> /etc/apt/sources.list
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN gpg -a --export E084DAB9 | apt-key add -
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
RUN apt update
RUN $APT_INSTALL r-base libcurl4-openssl-dev qpdf libssl-dev zlib1g-dev
RUN Rscript -e "install.packages(c('knitr', 'markdown', 'rmarkdown', 'testthat', 'devtools', 'e1071', 'survival', 'arrow', 'roxygen2', 'xml2'), repos='https://cloud.r-project.org/')"
