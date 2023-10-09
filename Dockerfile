# syntax=docker/dockerfile:1

ARG BUILD_BASE_VERSION
FROM ghcr.io/chrononeko/base:${BUILD_BASE_VERSION}

ARG TARGETARCH
ARG BUILD_CHRONO_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
  CHRONO_UID=911 \
  CHRONO_GID=1000 \
  CHRONO_UMASK=002 \
  CHRONO_ADMIN_LISTEN=0.0.0.0:16340

COPY --chmod=0755 rootfs /

RUN \
  # 下载 Chronocat
  mkdir -p /llqqnt/plugins && \
  cd /llqqnt/plugins && \
  curl -fsSLo chronocat.zip https://github.com/chrononeko/chronocat/releases/download/v${BUILD_CHRONO_VERSION}/chronocat-llqqnt-v${BUILD_CHRONO_VERSION}.zip && \
  unzip chronocat.zip && \
  rm chronocat.zip && \
  cd / && \
  \
  # 创建 chronocat 用户
  mkdir -p /chronocat && \
  useradd --no-log-init -d /chrono chronocat && \
  \
  # 清理
  # apt purge -y wget &&
  apt autoremove -y && \
  apt clean && \
  rm -rf \
  /var/lib/apt/lists/* \
  /tmp/* \
  /var/tmp/*

# Chronocat Red
EXPOSE 16530/tcp

# Chronocat Satori
EXPOSE 5500/tcp

# Chronocat Admin
EXPOSE 16340/tcp
