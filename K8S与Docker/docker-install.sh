#!/usr/bin/env bash

DOCKER_CE_VERSION=18.09.6-3.el7
DOCKER_CE_CLI_VERSION=18.09.6-3.el7

# 卸载旧版本
yum -y remove docker-ce.x86_64
yum -y remove containerd.io.x86_64
yum -y remove docker-ce-cli.x86_64

# 安装所需软件包
yum install -y  yum-utils \
                device-mapper-persistent-data \
                lvm2

# 设置存储库
# 阿里云 http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装最新版的docker-ce
yum -y install docker-ce-$DOCKER_CE_VERSION docker-ce-cli-$DOCKER_CE_CLI_VERSION containerd.io

# 配置阿里云docker镜像加速器
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://8auvmfwy.mirror.aliyuncs.com"],
   "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# 重新加载配置、重启docker
systemctl daemon-reload
systemctl restart docker
