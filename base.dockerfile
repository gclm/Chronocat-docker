# syntax=docker/dockerfile:1

FROM phusion/baseimage:jammy-1.0.1

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
  \
  # 安装依赖
  apt install -y \
  unzip \
  xorg xvfb x11-apps netpbm openbox \
  python3-xdg python3-numpy && \
  \
  # 下载 QQNT
  curl -fsSLo /tmp/qqnt.deb https://dldir1.qq.com/qqfile/qq/QQNT/ad5b5393/linuxqq_3.1.2-13107_${TARGETARCH}.deb && \
  apt install -y /tmp/qqnt.deb && \
  \
  # 下载 LiteLoaderQQNT
  cd /opt/QQ/resources/app && \
  curl -fsSLo LiteLoaderQQNT.zip https://github.com/LiteLoaderQQNT/LiteLoaderQQNT/releases/download/0.5.3/LiteLoaderQQNT.zip && \
  \
  # 安装 LiteLoaderQQNT
  unzip LiteLoaderQQNT.zip && \
  rm LiteLoaderQQNT.zip && \
  sed -i 's/.\/app_launcher\/index.js/.\/LiteLoader/' package.json && \
  cd / && \
  # 清理
  apt autoremove -y && \
  apt clean && \
  rm -rf \
  /var/lib/apt/lists/* \
  /tmp/* \
  /var/tmp/*
