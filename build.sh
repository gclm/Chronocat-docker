#!/bin/bash

set -euxo pipefail

source ./config.sh

BUILD_MODE=${1:-build}

BUILD_AUTO_TAG=$(git rev-parse --abbrev-ref HEAD)-$(git rev-list --count HEAD)
BUILD_TAG=${BUILD_TAG:-${BUILD_AUTO_TAG}}
BUILD_DOCKER_BUILDER=${BUILD_DOCKER_BUILDER:-container}

BUILD_ARCH_LIST=(
  amd64
  arm64
)

echo "Building chronoc/at:${BUILD_TAG} using builder: ${BUILD_DOCKER_BUILDER}\n\n"

for BUILD_ARCH in ${BUILD_ARCH_LIST[@]};
do
  BUILD_PLATFORM=linux/${BUILD_ARCH}

  BUILD_IMAGE_ARCH_TAG=${BUILD_TAG}-linux-${BUILD_ARCH}-up${BUILD_CHRONO_VERSION}

  case ${BUILD_MODE} in
    "push")
      if [ "$BUILD_TAG" = "$BUILD_AUTO_TAG" || "$BUILD_ARCH" != "amd64" ]
      then
        # 普通构建
        docker buildx build \
          --push \
          --builder=${BUILD_DOCKER_BUILDER} \
          --build-arg BUILD_ARCH=${BUILD_ARCH} \
          --build-arg BUILD_BASE_VERSION=${BUILD_BASE_VERSION} \
          --build-arg BUILD_CHRONO_VERSION=${BUILD_CHRONO_VERSION} \
          --build-arg BUILD_CHRONO_CLI_VERSION=${BUILD_CHRONO_CLI_VERSION} \
          --platform ${BUILD_PLATFORM} \
          -t ghcr.io/chrononeko/chronocat:${BUILD_TAG} \
          -t chronoc/at:${BUILD_TAG} \
          .
      else
        # 构建 latest 版本
        docker buildx build \
          --push \
          --builder=${BUILD_DOCKER_BUILDER} \
          --build-arg BUILD_ARCH=${BUILD_ARCH} \
          --build-arg BUILD_BASE_VERSION=${BUILD_BASE_VERSION} \
          --build-arg BUILD_CHRONO_VERSION=${BUILD_CHRONO_VERSION} \
          --build-arg BUILD_CHRONO_CLI_VERSION=${BUILD_CHRONO_CLI_VERSION} \
          --platform ${BUILD_PLATFORM} \
          -t ghcr.io/chrononeko/chronocat:${BUILD_TAG} \
          -t ghcr.io/chrononeko/chronocat:latest \
          -t chronoc/at:${BUILD_TAG} \
          -t chronoc/at:latest \
          .
      fi
      ;;
    *)
      docker buildx build \
        --builder=${BUILD_DOCKER_BUILDER} \
        --build-arg BUILD_ARCH=${BUILD_ARCH} \
        --build-arg BUILD_BASE_VERSION=${BUILD_BASE_VERSION} \
        --build-arg BUILD_CHRONO_VERSION=${BUILD_CHRONO_VERSION} \
        --build-arg BUILD_CHRONO_CLI_VERSION=${BUILD_CHRONO_CLI_VERSION} \
        --platform ${BUILD_PLATFORM} \
        -t ghcr.io/chrononeko/chronocat:${BUILD_IMAGE_ARCH_TAG} \
        -t chronoc/at:${BUILD_IMAGE_ARCH_TAG} \
        .
      ;;
  esac
done
