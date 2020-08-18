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
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装最新版的docker-ce
yum -y install docker-ce-$DOCKER_CE_VERSION docker-ce-cli-$DOCKER_CE_CLI_VERSION containerd.io

# 配置阿里云docker镜像加速器,配置私有镜像仓库地址
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://8auvmfwy.mirror.aliyuncs.com"],
   "exec-opts": ["native.cgroupdriver=systemd"],
   "insecure-registries": ["192.168.12.124:7080"]
}
EOF

# 重新加载配置、重启docker
systemctl daemon-reload
systemctl restart docker
