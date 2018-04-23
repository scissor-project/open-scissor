#!/bin/sh -e

test_docker_container () (
    container_full_name="$1"
    container_name="$2"
    test_path="$3"
    echo "Running test on $container_full_name (short name: $container_name) container. Test path: $test_path"
    inspec exec "$test_path" -t docker://"$container_full_name"
)

set -e

if ! TEMP="$(getopt -o vdm: --long docker-context-path:,max_tries:,only:,skip-build,skip-pull,skip-start -n 'test-docker-image' -- "$@")" ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

docker_context_path=
max_tries=50
only=
skip_build=false
skip_pull=false
skip_start=false

while true; do
  case "$1" in
    -b | --skip-build ) skip_build=true; shift 1 ;;
    -c | --docker-context-path ) docker_context_path="$2"; shift 2 ;;
    -m | --max-tries ) max_tries="$2"; shift 2 ;;
    -o | --only ) only="$2"; shift 2 ;;
    -p | --skip-pull ) skip_pull=true; shift 1 ;;
    -s | --skip-start ) skip_start=true; shift 1 ;;
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

  docker_compose_file_name="docker-compose.yml"
  docker_compose_file_name_travis="docker-compose.travis.yml"

  if [ "$TRAVIS" = "true" ]; then
    sed "s/latest/$TRAVIS_BUILD_NUMBER/g" "$docker_context_path"/"$docker_compose_file_name" > "$docker_context_path"/"$docker_compose_file_name_travis"
    docker_compose_file_name="$docker_compose_file_name_travis"
  fi
  echo "Using $docker_compose_file_name file"

  if [ "$skip_build" = true ] ; then
    echo "Skipping image building phase"
  else
    echo "Building images"
    docker-compose --file "$docker_context_path"/"$docker_compose_file_name" build
  fi

  if [ "$skip_pull" = true ] ; then
    echo "Skipping image pulling phase"
  else
    echo "Pulling images from the registry"
    docker-compose --file "$docker_context_path"/"$docker_compose_file_name" pull
  fi

  if [ "$skip_start" = true ] ; then
    echo "Skipping container start phase"
  else
    echo "Starting services"
    docker-compose --file "$docker_context_path"/"$docker_compose_file_name" up -d --force-recreate --no-build
  fi

  SCRIPT=$(readlink -f "$0")
  SCRIPT_PATH=$(dirname "$SCRIPT")
  # shellcheck source=/dev/null
  . "$SCRIPT_PATH"/wait-for-docker-init.sh

  echo "Running tests on containers"
  test_path_prefix="test/inspec/docker"
  docker-compose --file "$docker_context_path"/"$docker_compose_file_name" ps -q | while read -r container_id; do
    container_full_name="$(docker inspect --format='{{.Name}}' "$container_id" | tr --delete "/")"
    container_name_prefix="scissorproject-"
    container_name="${container_full_name#"$container_name_prefix"}"
    wait_method_name="$(echo "$container_name" | tr - _)"_is_ready
    echo "Waiting for $container_name to start"
    wait_until_service_is_ready "$wait_method_name" "$container_name" "$docker_context_path"/"$docker_compose_file_name" "$max_tries"
    test_docker_container "$container_full_name" "$container_name" "$test_path_prefix/$container_name"
  done

  echo "Stopping and removing services"
  docker-compose --file "$docker_context_path"/"$docker_compose_file_name" down --volumes --remove-orphans
fi;
