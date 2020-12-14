KMS搭建
简介
KMS使用的工具和技术的概述：
⦁	使用C和C++语言编写
⦁	CMake是首选的构建工具，用于构建所有模块
⦁	官方支持的平台是Ubuntu 16.04和Ubuntu18.04
⦁	GStreamer多媒体框架是KMS核心
⦁	其它库：boost，jsoncpp，libnice等
构成KMS的所有repos依赖关系：
 
主要的repos：
⦁	kurento-module-creator
代码生成工具，用于为插件生成代码支架，包括KMS代码和Kurento客户代码。主要是Java代码。
⦁	kms-cmake-utils
用于使用Cmake构建KMS的应用程序
⦁	kms-jsonrpc
Kurento协议基于JsonRpc，并使用了此库中包含的JsonRpc库，C++代码
⦁	kms-core 
包含核心Gstreamer代码，是其它库所需的基础库
⦁	kms-elements
包含提供管道功能的主要元素，例如WebRTC、RTP、Player、Recorder等
⦁	kms-filters
包含KMS中基本的视频过滤器
⦁	kurento-media-server
是KMS的主入口，提供服务器可执行的代码main()函数


源码编译
编译环境
KMS是以Ubuntu系统为目标的C/C++项目，其依赖项管理和分发基于Ubuntu软件包系统。
 

安装所需工具
sudo apt-get update && sudo apt-get install --no-install-recommends --yes \
    build-essential \
    ca-certificates \
    cmake \
gnupg

添加Kurento存储库
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5AFA7A83
DISTRO="xenial"  # KMS for Ubuntu 16.04 (Xenial)
DISTRO="bionic"  # KMS for Ubuntu 18.04 (Bionic)
sudo tee "/etc/apt/sources.list.d/kurento.list" >/dev/null <<EOF
# Kurento Media Server - Nightly packages
deb [arch=amd64] http://ubuntu.openvidu.io/dev $DISTRO kms6
EOF
sudo apt-get update

安装编译依赖
sudo apt-get update && sudo apt-get install --no-install-recommends --yes \
    kurento-media-server-dev

生成并运行
进入到kurento-omni-build目录
export MAKEFLAGS="-j$(nproc)"
./bin/kms-build-run.sh


构建Docker镜像(待补充)
⦁	编写Dockerfile
# Dockerfile
# Kurento Media Server
#
# 构建此镜像用于运行Kurento Media Server实例
#
#
# 构建命令
# -------------
#
# docker build [Args...] --tag huayu/kurento-media-server:latest .
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
#
# --build-arg KMS_VERSION=<KmsVersion>
#
#   <KmsVersion>: "6.9.0", "6.13.0", 等.
#   或者"dev"，不可用于生产环境.
#
#   可选. 默认: "dev".
#
#
# 运行命令
# -----------
#
# docker run --name kms -d -p 8888:8888 huayu/kurento-media-server:latest
#
# 可以使用docker日志跟踪命令：
#
# docker logs --follow kms >"kms-$(date '+%Y%m%dT%H%M%S').log" 2>&1

ARG UBUNTU_VERSION="xenial"

FROM ubuntu:${UBUNTU_VERSION}

ARG UBUNTU_VERSION="xenial"
ARG KMS_VERSION="dev"

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
 && echo "KMS_VERSION=${KMS_VERSION}" \
 && echo "Apt source line: deb [arch=amd64] http://ubuntu.openvidu.io/${KMS_VERSION} ${UBUNTU_VERSION} kms6" \
 && echo "deb [arch=amd64] http://ubuntu.openvidu.io/${KMS_VERSION} ${UBUNTU_VERSION} kms6" >/etc/apt/sources.list.d/kurento.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5AFA7A83



# 安装额外的modules
RUN apt-get update && apt-get install --yes \
        kms-chroma \
        kms-crowddetector \
        kms-platedetector \
        kms-pointerdetector \
    || true \
 && rm -rf /var/lib/apt/lists/*

# 配置KMS环境. 可以通过`docker run`进行覆盖
ENV GST_DEBUG="3,Kurento*:4,kms*:4,sdp*:4,webrtc*:4,*rtpendpoint:4,rtp*handler:4,rtpsynchronizer:4,agnosticbin:4" \
    GST_DEBUG_NO_COLOR=1 \
    KMS_MTU="" \
    KMS_EXTERNAL_ADDRESS="" \
    KMS_NETWORK_INTERFACES="" \
    KMS_STUN_IP="" \
    KMS_STUN_PORT="" \
    KMS_TURN_URL=""

# 开放端口
EXPOSE 8888

COPY ./entrypoint.sh /entrypoint.sh
COPY ./healthchecker.sh /healthchecker.sh

HEALTHCHECK --start-period=15s --interval=30s --timeout=3s --retries=1 CMD /healthchecker.sh

ENTRYPOINT ["/entrypoint.sh"]

⦁	编写健康检查脚本healthchecker.sh

⦁	编写入口脚本entrypoint.sh

⦁	运行构建
docker build --build-arg 'KMS_VERSION=6.13.0' –-tag huayu/kurento-media-server:latest .

⦁	运行
docker run -d --name kms -p 8888:8888 \
    -v /tmp:/tmp \
    -e KMS_STUN_IP="183.56.219.127" \
    -e KMS_STUN_PORT="3478" \
    -e KMS_TURN_URL="kurento:kurento@183.56.219.127:3478" \
    -e OUTPUT_BITRATE="2048000" \
    huayu/kurento-media-server:latest
