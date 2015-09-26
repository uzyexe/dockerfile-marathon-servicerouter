# uzyexe/marathon-servicerouter

This is servicerouter.py docker container.

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

Command example of generating the `ca-bundle.pem`: `cat key.pem cert.pem > ca-bundle.pem`

### Normal running

It run an `/marathon/bin/servicerouter.py --marathon http://127.0.0.1:8080`.

```
docker run -d \
  --name="servicerouter" \
  --net="host" \
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
  --volume="/dev/log:/dev/log" \
  --volume="/tmp/ca-bundle.pem:/etc/ssl/mesosphere.com.pem:ro" \
  --volume="/tmp/servicerouter.sh:/cron/servicerouter.sh" \
  uzyexe/marathon-servicerouter
```
