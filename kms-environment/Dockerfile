# Environment For KMS
#
# 构建此镜像用于KMS的运行环境
#
# 构建KMS镜像耗时长，大多集中在运行环境的构建，并且运行环境一般情况不变，故把运行环境与编译文件分开构建。
#
#
# 构建命令
# -------------
#
# docker build [Args...] --tag huayu/kms-environment:[xenial or bionic] .
#
#
# 构建参数
# ---------------
#
# --build-arg UBUNTU_VERSION=<UbuntuVersion>
#
#   <UbuntuVersion>: "xenial", "bionic".
#
#   可选. 默认: "xenial".

ARG UBUNTU_VERSION="xenial"

FROM ubuntu:${UBUNTU_VERSION}

ARG UBUNTU_VERSION="xenial"

# 修改`apt-get`软件源
COPY ./sources-${UBUNTU_VERSION}.list /etc/apt/sources.list

# 配置环境：
# * DEBIAN_FRONTEND: 禁用`apt-get`交互
# * LANG: 设置默认地区编码
ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="C.UTF-8"

# 安装工具：
# * gnupg: For `apt-key adv` (since Ubuntu 18.04)
# * curl: For "entrypoint.sh" and "healthchecker.sh"
RUN apt-get update && apt-get install --yes \
        gnupg \
        curl \
 && rm -rf /var/lib/apt/lists/*

# 配置`apt-get`：
# * 禁用推荐和建议的软件包
# * 添加Kurento仓库
RUN echo 'APT::Install-Recommends "false";' >/etc/apt/apt.conf.d/00recommends \
 && echo 'APT::Install-Suggests "false";' >>/etc/apt/apt.conf.d/00recommends \
 && echo "UBUNTU_VERSION=${UBUNTU_VERSION}" \
 && echo "Apt source line: deb [arch=amd64] http://ubuntu.openvidu.io/6.13.0 ${UBUNTU_VERSION} kms6" \
 && echo "deb [arch=amd64] http://ubuntu.openvidu.io/6.13.0 ${UBUNTU_VERSION} kms6" >/etc/apt/sources.list.d/kurento.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5AFA7A83

# 安装依赖
RUN apt-get update && apt-get install --yes \
        Kurento-media-server-dev \
 && rm -rf /var/lib/apt/lists/*
