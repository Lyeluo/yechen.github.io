#!/usr/bin/env bash
set -e

ECS_CONSOLE_URL=$1
DB_URL=$2
DB_USERNAME=$3
DB_PASSWORD=$4
ECS_JOB_PORT=$5
ECS_JOB_VERSION=$6


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
	echo "ecs-job开始安装...."
    docker load -i ecs-job-center.tar

    docker run -e ECS_CONSOLE_URL=${ECS_CONSOLE_URL} \
    -e DB_URL=${DB_URL} \
    -e DB_USERNAME=${DB_USERNAME} \
    -e DB_PASSWORD=${DB_PASSWORD} \
    -e ACCESS_TOKEN=ms-yuanian \
    --name ecs-job-center -d -p ${ECS_JOB_PORT}:8081 --restart=always ecs-job-center:${ECS_JOB_VERSION}
}


# 执行函数
docker_install
ecs_job_install
