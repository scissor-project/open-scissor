#!/bin/sh

docker_image_tag="scissor/dnsmasq:latest"
result=$(docker images -q scissor/dnsmasq:latest )

if [ -n "$result" ]; then
  echo "$docker_image_tag image already built"
else
  echo "Building $docker_image_tag image"
  cd /tmp/scissor-dnsmasq
  docker build -t $docker_image_tag .
fi
