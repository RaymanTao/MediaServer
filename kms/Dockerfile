# KMS
#
# 构建此镜像用于运行KMS实例
#
# 构建KMS镜像耗时长，大多集中在运行环境的构建，并且运行环境一般情况不变，故把运行环境与编译文件分开构建。
# 在构建此镜像前，请先构建huayu/kms-environment:xenial或huayu/kms-environment:bionic，这取决于UbuntuVersion，请参照构建参数。
#
#
# 构建命令
# -------------
#
# docker build [Args...] --tag huayu/kms:latest .
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
#
# 运行命令
# -----------
#
# docker run --name kms -d -p 8888:8888 huayu/kms:latest
#
# 可以使用docker日志跟踪命令：
#
# docker logs --follow kms >"kms-$(date '+%Y%m%dT%H%M%S').log" 2>&1

ARG UBUNTU_VERSION="xenial"

FROM huayu/kms-environment:${UBUNTU_VERSION}

ARG UBUNTU_VERSION="xenial"

# 复制文件
COPY ./build-RelWithDebInfo /kms/
COPY ./entrypoint.sh /kms/entrypoint.sh
COPY ./healthchecker.sh /kms/healthchecker.sh

# 修改权限
# 安装额外的modules
RUN chmod -R 777 /kms

# 配置KMS环境. 可以通过`docker run`进行覆盖
ENV GST_DEBUG="3,Kurento*:4,kms*:4,sdp*:4,webrtc*:4,*rtpendpoint:4,rtp*handler:4,rtpsynchronizer:4,agnosticbin:4" \
    GST_DEBUG_NO_COLOR=1 \
    KMS_MTU="" \
    KMS_EXTERNAL_ADDRESS="" \
    KMS_NETWORK_INTERFACES="" \
    KMS_STUN_IP="" \
    KMS_STUN_PORT="" \
    KMS_TURN_URL=""

# 暴露端口
EXPOSE 8888

# 健康检查脚本
HEALTHCHECK --start-period=15s --interval=30s --timeout=3s --retries=1 CMD /kms/healthchecker.sh

# 配置入口脚本
ENTRYPOINT ["/kms/entrypoint.sh"]
