#!/bin/sh -e

DOCKER_REPO="scissorproject/openscissor"
DOCKER_IMAGE_ID_BUILD_NUMBER="$DOCKER_REPO":"$IMAGE_NAME-$TRAVIS_BUILD_NUMBER"
echo "Uploading image under $DOCKER_IMAGE_ID_BUILD_NUMBER tag"
docker tag "$DOCKER_REPO:$IMAGE_NAME-latest" "$DOCKER_IMAGE_ID_BUILD_NUMBER"

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
docker push "$DOCKER_IMAGE_ID_BUILD_NUMBER"
