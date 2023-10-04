# syntax=docker/dockerfile:1

ARG BUILD_BASE_VERSION
FROM ghcr.io/chrononeko/base:${BUILD_BASE_VERSION}

ARG TARGETARCH
ARG BUILD_CHRONO_VERSION
ARG BUILD_CHRONO_CLI_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
  CHRONO_UID=911 \
  CHRONO_GID=1000 \
  CHRONO_UMASK=002 \
  CHRONO_ADMIN_LISTEN=0.0.0.0:16340

RUN \
  # 下载 Chronocat
  mkdir -p /llqqnt/plugins && \
  cd /llqqnt/plugins && \
  curl -fsSLo chronocat.zip https://github.com/chrononeko/chronocat/releases/download/v${BUILD_CHRONO_VERSION}/chronocat-llqqnt-v${BUILD_CHRONO_VERSION}.zip && \
  unzip chronocat.zip && \
  rm chronocat.zip && \
  cd / && \
  \
  # 下载 Chronocat CLI
  curl -fsSLo /opt/chronocat \
  https://github.com/chrononeko/cli/releases/download/v${BUILD_CHRONO_CLI_VERSION}/chronocat-$([ "${TARGETARCH}" == "amd64" ] && echo "x86_64" || echo "aarch64")-unknown-linux-gnu-v${BUILD_CHRONO_CLI_VERSION} && \
  chmod +x /opt/chronocat && \
  \
  # 创建 chrono 用户
  mkdir -p /chrono && \
  useradd --no-log-init -d /chrono chrono && \
  \
  # 清理
  # apt purge -y wget &&
  apt autoremove -y && \
  apt clean && \
  rm -rf \
  /var/lib/apt/lists/* \
  /tmp/* \
  /var/tmp/*
