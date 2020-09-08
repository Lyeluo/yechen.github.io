#!/usr/bin/env bash
set -o errexit

CURRENT_PATH=$(pwd)

function docker_install()
{
	echo "检查Docker......"
	docker -v
    if [ $? -eq  0 ]; then
        echo "检查到Docker已安装!"
    else
    	echo "安装docker环境..."
        sh ./docker-install.sh
        echo "安装docker环境...安装完成!"
    fi
    # 创建公用网络==bridge模式
    #docker network create share_network
}

function ecs_job_install()
{

    if [ ! -d ${CURRENT_PATH}/redis-data  ];then
      mkdir redis-data
    else
      echo 'dir redis-data exist'
    fi
    docker load -i ecs-redis.tar
    docker run -d --name ecs-redis -p 6379:6379 -v ${CURRENT_PATH}/redis-data:/data --restart=always ecs-redis:6.0 --appendonly yes
    echo "Redis已启动...!"
}


# 安装docker
docker_install
# 安装redis
ecs_job_install

