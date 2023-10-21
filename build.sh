#!/bin/bash

set -euxo pipefail

source ./config.sh

BUILD_MODE=${1:-build}

BUILD_AUTO_TAG=$(git rev-parse --abbrev-ref HEAD)-$(git rev-list --count HEAD)
BUILD_TAG=${BUILD_TAG:-${BUILD_AUTO_TAG}}
BUILD_DOCKER_BUILDER=${BUILD_DOCKER_BUILDER:-container}

BUILD_PLATFORM=linux/amd64,linux/arm64

echo "Building gclm/chronocat:${BUILD_TAG} using builder: ${BUILD_DOCKER_BUILDER}\n\n"

case ${BUILD_MODE} in
  "push")
    if [ "$BUILD_TAG" = "$BUILD_AUTO_TAG" ]
    then
      # 未给定构建 Tag，进行普通构建
      docker buildx build \
        --push \
        --builder=${BUILD_DOCKER_BUILDER} \
        --build-arg BUILD_CHRONO_VERSION=${BUILD_CHRONO_VERSION} \
        --platform ${BUILD_PLATFORM} \
        -t ghcr.io/gclm/chronocat:${BUILD_TAG} \
        -t gclmit/chronocat:${BUILD_TAG} \
        .
    else
      # 使用给定 Tag 进行构建，同时构建 latest 版本
      docker buildx build \
        --push \
        --builder=${BUILD_DOCKER_BUILDER} \
        --build-arg BUILD_CHRONO_VERSION=${BUILD_CHRONO_VERSION} \
        --platform ${BUILD_PLATFORM} \
        -t ghcr.io/gclm/chronocat:${BUILD_TAG} \
        -t ghcr.io/gclm/chronocat:latest \
        -t gclmit/chronocat:${BUILD_TAG} \
        -t gclmit/chronocat:latest \
        .
    fi
    ;;
  *)
    docker buildx build \
      --builder=${BUILD_DOCKER_BUILDER} \
      --build-arg BUILD_CHRONO_VERSION=${BUILD_CHRONO_VERSION} \
      --platform ${BUILD_PLATFORM} \
      -t gclmit/chronocat:${BUILD_TAG} \
      .
    ;;
esac
