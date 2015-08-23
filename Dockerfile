FROM python:2.7.10-slim

ENV MARATHON_VERSION 0.10.0

# install haproxy and mercurial and marathon code
ADD https://github.com/mesosphere/marathon/archive/v${MARATHON_VERSION}.tar.gz marathon.tar.gz

RUN mkdir marathon && tar xvzf marathon.tar.gz -C marathon --strip-components 1 && \
    rm marathon.tar.gz && \
    pip install -e hg+https://bitbucket.org/dbenamy/devcron#egg=devcron requests

RUN apt-get update -qq && \
    apt-get install -qy haproxy mercurial && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Setup defaults
RUN mkdir /cron &&\
    echo "* * * * * /cron/servicerouter.sh" > /cron/crontab && \
    echo "/marathon/bin/servicerouter.py --marathon http://127.0.0.1:8080" > /cron/servicerouter.sh && \
    chmod a+x /cron/servicerouter.sh

VOLUME ["/cron"]

CMD ["/usr/local/bin/devcron.py /cron/crontab"]

EXPOSE 80 443
