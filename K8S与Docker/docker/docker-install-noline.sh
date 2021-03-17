#!/usr/bin/env bash

# 加载离线安装包
rpm -Uvh --force --nodeps ./*.rpm

# 配置阿里云docker镜像加速器,配置私有镜像仓库地址
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://8auvmfwy.mirror.aliyuncs.com"],
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
    "log-opts": {
		"max-size": "50m",
		"max-file": "3"
	}
}
EOF

# 重新加载配置、重启docker
systemctl daemon-reload
systemctl restart docker
systemctl enable docker.service




