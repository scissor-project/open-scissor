#!/bin/sh -e

test_docker_container () (
    container_full_name="$1"
    container_name="$2"
    test_path="$3"
    echo "Running test on $container_full_name (short name: $container_name) container. Test path: $test_path"
    inspec exec "$test_path" -t docker://"$container_full_name"
)

set -e

if ! TEMP="$(getopt -o vdm: --long docker-context-path:,only: -n 'test-docker-image' -- "$@")" ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

docker_context_path=
only=

while true; do
  case "$1" in
    -c | --docker-context-path ) docker_context_path="$2"; shift 2 ;;
    -o | --only ) only="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ "$only" = "lint-dockerfile" ] || [ -z "$only" ]; then
  echo "Linting Dockerfiles from $docker_context_path"
  find "$docker_context_path" -type f -iname "Dockerfile" | while read -r line; do
    echo "Linting $line"
    # Ignore DL3013: https://github.com/hadolint/hadolint/issues/157
    # Ignore DL3016: https://github.com/hadolint/hadolint/issues/151 https://github.com/hadolint/hadolint/issues/152 https://github.com/hadolint/hadolint/issues/153
    # Ignore SC1090 because hadolint does not (yet) allow to disable rules in the Dockerfile
    docker run -v "$(pwd)":/mnt --rm -w="/mnt" hadolint/hadolint:v1.2.6 hadolint --ignore DL3013 --ignore DL3016 --ignore SC1090 "$line"
  done
fi;

if [ "$only" = "lint-shell" ] || [ -z "$only" ]; then
  echo "Linting shell scripts from $docker_context_path"
  find "$docker_context_path" -type f -iname "*.sh" | while read -r line; do
    echo "Linting $line"
    docker run -v "$(pwd)":/mnt --rm koalaman/shellcheck:v0.4.7 "$line"
  done
fi;

if [ "$only" = "integration" ] || [ -z "$only" ]; then
  echo "Running docker-compose from $docker_context_path"

  echo "Building images"
  docker-compose --file "$docker_context_path"/docker-compose.yml build

  echo "Starting services"
  docker-compose --file "$docker_context_path"/docker-compose.yml up -d --force-recreate

  echo "Waiting for containers to start"
  sleep 60

  echo "Running tests on containers"
  test_path_prefix="test/inspec/docker"
  docker-compose --file "$docker_context_path"/docker-compose.yml ps -q | while read -r container_id; do
    container_full_name="$(docker inspect --format='{{.Name}}' "$container_id" | tr --delete "/")"
    container_name_prefix="scissorproject-"
    container_name="${container_full_name#"$container_name_prefix"}"
    test_docker_container "$container_full_name" "$container_name" "$test_path_prefix/$container_name"
  done

  echo "Stopping and removing services"
  docker-compose --file "$docker_context_path"/docker-compose.yml down --volumes --remove-orphans
fi;
