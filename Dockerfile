FROM phusion/baseimage:jammy-1.0.1

ARG BUILD_CHRONO_VERSION
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
  CHRONO_UID=911 \
  CHRONO_GID=1000 \
  CHRONO_UMASK=002 \
  CHRONO_ADMIN_LISTEN=0.0.0.0:16340

COPY --chmod=0755 rootfs /

# 安装依赖
RUN apt update  \
  && apt install -y \
  unzip lsof \
  xorg xvfb x11-apps netpbm openbox \
  python3-xdg python3-numpy

# 安装环境
RUN curl -fsSLo /tmp/qqnt.deb https://dldir1.qq.com/qqfile/qq/QQNT/ad5b5393/linuxqq_3.1.2-13107_${TARGETARCH}.deb  \
    && apt install -y /tmp/qqnt.deb  \
    # 安装 LiteLoaderQQNT
    && cd /opt/QQ/resources/app  \
    && curl -fsSLo LiteLoaderQQNT.zip https://github.com/LiteLoaderQQNT/LiteLoaderQQNT/releases/download/0.5.3/LiteLoaderQQNT.zip  \
    && unzip LiteLoaderQQNT.zip  \
    && rm LiteLoaderQQNT.zip  \
    && sed -i 's/.\/app_launcher\/index.js/.\/LiteLoader/' package.json  \
    # 安装 chronocat-llqqnt
    && mkdir -p /llqqnt/plugins  \
    && cd /llqqnt/plugins  \
    && curl -fsSLo chronocat.zip https://github.com/gclm/chronocat/releases/download/v${BUILD_CHRONO_VERSION}/chronocat-llqqnt-v${BUILD_CHRONO_VERSION}.zip \
    && unzip chronocat.zip  \
    && rm chronocat.zip \
    # 创建 chronocat 用户
    && mkdir -p /chronocat  \
    && useradd --no-log-init -d /chrono chronocat

# 清理
RUN apt autoremove -y  \
  && apt clean  \
  && rm -rf  /var/lib/apt/lists/*  /tmp/*  /var/tmp/*

# Chronocat Red
EXPOSE 16530/tcp

# Chronocat Satori
EXPOSE 5500/tcp

# Chronocat Admin
EXPOSE 16340/tcp
