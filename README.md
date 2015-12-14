# uzyexe/marathon-servicerouter

This is servicerouter.py docker container.

# This Image is Deprecated

It is recommended that you use the [marathon-lb](https://github.com/mesosphere/marathon-lb) Image.


## What is servicerouter.py

servicerouter.py is a replacement for the haproxy-marathon-bridge implemented in Python. It reads Marathon task information and generates haproxy configuration. It supports advanced functions like sticky sessions, HTTP to HTTPS redirection, SSL offloading, VHost support and templating.
servicerouter.py depends on the Marathon Framework.

[https://mesosphere.github.io/marathon/](https://mesosphere.github.io/marathon/)

[https://github.com/mesosphere/marathon/blob/master/bin/servicerouter.py](https://github.com/mesosphere/marathon/blob/master/bin/servicerouter.py)

## Dockerfile

[**Trusted Build**](https://registry.hub.docker.com/u/uzyexe/marathon-servicerouter/)

This Docker image is based on the official [python:2.7.10](https://registry.hub.docker.com/_/python/) base image.

## How to use this image

info: `/tmp/ca-bundle.pem` is SSL private key + SSL Certificate combined file.

Command example of generating the ca-bundle.pem: `cat key.pem cert.pem > ca-bundle.pem`

### Normal running

It run an `/marathon/bin/servicerouter.py --marathon http://127.0.0.1:8080`.

```
docker run -d \
  --name="servicerouter" \
  --net="host" \
  --ulimit nofile=8204 \
  --volume="/dev/log:/dev/log" \
  --volume="/tmp/ca-bundle.pem:/etc/ssl/mesosphere.com.pem:ro" \
  uzyexe/marathon-servicerouter
```

### Custom servicerouter.sh

It run an custom options servicerouter.py

```
echo "/marathon/bin/servicerouter.py --marathon http://username:password@127.0.0.1:8080" > /tmp/servicerouter.sh 
chmod +x /tmp/servicerouter.sh

docker run -d \
  --name="servicerouter" \
  --net="host" \
  --ulimit nofile=8204 \
  --volume="/dev/log:/dev/log" \
  --volume="/tmp/ca-bundle.pem:/etc/ssl/mesosphere.com.pem:ro" \
  --volume="/tmp/servicerouter.sh:/cron/servicerouter.sh" \
  uzyexe/marathon-servicerouter
```

### Custom HAProxy Templates


The servicerouter searches for configuration files in the /templates directory.
The /templates directory contains servicerouter configuration settings and example usage.
The /templates directory is located in a relative path from where the script is run.

https://github.com/mesosphere/marathon/blob/master/bin/servicerouter.py#L72

```
mkdir -p /opt/servicerouter/templates
cat <<-'EOF' > /opt/servicerouter/templates/HAPROXY_HEAD
global
  daemon
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  maxconn 20000
  nbproc  6

defaults
  log               global
  retries           3
  maxconn           2000
  timeout connect   5000ms
  timeout client    50000ms
  timeout server    50000ms
EOF

/usr/bin/docker run \
  -d \
  --name="servicerouter" \
  --net="host" \
  --ulimit nofile=40011 \
  --volume="/tmp/ca-bundle.pem:/etc/ssl/mesosphere.com.pem:ro" \
  --volume="/opt/servicerouter/templates:/templates:ro" \
  --volume="/var/log/haproxy:/var/log/haproxy:ro" \
  uzyexe/servicerouter
```

### Shared HAProxy log

```
/usr/bin/docker run \
  -d \
  --name="servicerouter" \
  --net="host" \
  --ulimit nofile=8204 \
  --volume="/tmp/ca-bundle.pem:/etc/ssl/mesosphere.com.pem:ro" \
  --volume="/var/log/haproxy:/var/log/haproxy:ro" \
  uzyexe/servicerouter
```
