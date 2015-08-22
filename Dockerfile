FROM python:2.7.10-slim

ENV MARATHON_VERSION 0.10.0

ADD https://github.com/mesosphere/marathon/archive/v${MARATHON_VERSION}.tar.gz marathon.tar.gz

RUN mkdir marathon && tar xvzf marathon.tar.gz -C marathon --strip-components 1 && \
    rm marathon.tar.gz && \
    pip install requests

RUN apt-get update -qq && \
    apt-get install -qy haproxy && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/marathon/bin/servicerouter.py"]

EXPOSE 80
