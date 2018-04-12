#!/bin/sh -e

if [ "$TRAVIS_PULL_REQUEST" = "false" ] && [ "$TRAVIS_BRANCH" = "master" ] ; then
  PULL_REQUEST_BRANCH="latest"
else
  PULL_REQUEST_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
fi

DOCKER_REPO="scissorproject/openscissor"
DOCKER_IMAGE_ID="$DOCKER_REPO":"${IMAGE_NAME}-${PULL_REQUEST_BRANCH}"
DOCKER_IMAGE_ID_BUILD_NUMBER="$DOCKER_REPO":"${IMAGE_NAME}-${PULL_REQUEST_BRANCH}-${TRAVIS_BUILD_NUMBER}"

docker tag "scissorproject/$IMAGE_NAME:latest" "$DOCKER_IMAGE_ID"
docker tag "scissorproject/$IMAGE_NAME:latest" "$DOCKER_IMAGE_ID_BUILD_NUMBER"

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
docker push "$DOCKER_IMAGE_ID"
docker push "$DOCKER_IMAGE_ID_BUILD_NUMBER"
