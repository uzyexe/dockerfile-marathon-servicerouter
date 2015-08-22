FROM python:2.7.10

ENV MARATHON_VERSION 0.10.0

ADD https://github.com/mesosphere/marathon/archive/v${MARATHON_VERSION}.tar.gz marathon.tar.gz

RUN mkdir marathon && tar xvzf marathon.tar.gz -C marathon --strip-components 1 && \
    rm marathon.tar.gz

RUN curl -sL https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python && \
    easy_install pip && \
    pip install requests

ENTRYPOINT ["/marathon/bin/servicerouter.py"]
