#!/bin/sh -e

set -e

if ! TEMP="$(getopt -o vdm: --long docker-context-path: -n 'test-docker-image' -- "$@")" ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"


docker_context_path=

while true; do
  case "$1" in
    -c | --docker-context-path ) docker_context_path="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

docker_container_name="$(basename "$docker_context_path")"
docker_image_id="$docker_container_name:latest"
test_id="$docker_container_name"
test_path="test/inspec/docker/$test_id/"
echo "Running test on $docker_context_path. Container name: $docker_container_name, Image id: $docker_image_id, Test path: $test_path"

if [ "$(docker ps -q -f name="$docker_container_name")" ]; then
  echo "Killing $docker_container_name container"
  docker kill "$docker_container_name" > /dev/null 2>&1
  docker rm "$docker_container_name" > /dev/null 2>&1
fi

docker build -t "$docker_image_id" "$docker_context_path"
docker run -d --hostname="$docker_container_name" --name="$docker_container_name" "$docker_image_id"
inspec exec "$test_path" -t docker://"$docker_container_name"
docker kill "$docker_container_name" > /dev/null 2>&1
docker rm "$docker_container_name" > /dev/null 2>&1
