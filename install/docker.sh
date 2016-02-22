#!/bin/bash

set -e

# configure docker
echo "DOCKER_OPTS=\"-H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock\"" >> /etc/default/docker
service docker restart
