#!/bin/bash

set -euxo pipefail

BUILD_MODE=${1:-build}

BUILD_AUTO_TAG=$(git rev-parse --abbrev-ref HEAD)-$(git rev-list --count HEAD)
BUILD_TAG=${BUILD_TAG:-${BUILD_AUTO_TAG}}
BUILD_DOCKER_BUILDER=${BUILD_DOCKER_BUILDER:-container}

BUILD_PLATFORM=linux/amd64,linux/arm64

echo "Building chronoc/base:${BUILD_TAG} using builder: ${BUILD_DOCKER_BUILDER}\n\n"

case ${BUILD_MODE} in
"push")
    docker buildx build \
      --push \
      --builder=${BUILD_DOCKER_BUILDER} \
      --platform ${BUILD_PLATFORM} \
      -f base.dockerfile \
      -t ghcr.io/chrononeko/base:${BUILD_TAG} \
      .
    ;;
  *)
    docker buildx build \
      --builder=${BUILD_DOCKER_BUILDER} \
      --platform ${BUILD_PLATFORM} \
      -f base.dockerfile \
      -t ghcr.io/chrononeko/base:${BUILD_TAG} \
      .
    ;;
esac
