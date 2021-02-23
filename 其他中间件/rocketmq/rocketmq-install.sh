#!/usr/bin/env bash
str=$"\n"
#CURRENT_HOST=$1
CURRENT_HOST=127.0.0.1
CURRENT_PATH=$(pwd)




function jdk_install()
{
	echo "检查JDK......"
	java -version
    if [ $? -eq  0 ]; then
        echo "检查到jdk已安装!"
    else
    	echo "安装jdk环境..."
        yum -y install java-1.8.0-openjdk
        echo "安装jdk环境...安装完成!"
    fi
    yum install -y java-1.8.0-openjdk-devel.x86_64

}

function stop_old_rocketmq() {
    set -o errexit

    consolePid=`jps | grep -e rocketmq-console-ng-1.0.1.jar| awk '{print $1}'`
    if [  ! -n "$consolePid" ]; then
        echo "rocketmq-console 准备启动..."
    else
        kill  $consolePid
    fi

    namesrvPid=`jps | grep -e NamesrvStartup| awk '{print $1}'`
    if [  ! -n "$namesrvPid" ]; then
        echo "rocketmq-namesrv 准备启动..."
    else
        kill  $namesrvPid
    fi

    brokerPid=`jps | grep -e BrokerStartup| awk '{print $1}'`
    if [  ! -n "$brokerPid" ]; then
        echo "rocketmq-broker 准备启动..."
    else
        kill  $brokerPid
    fi
}


function start_new_rocketmq()
{
    set -o errexit
    echo "安装rocketMQ...开始安装!"

    cp -f ${CURRENT_PATH}/rocketmq-4.7.1/conf/broker.conf ${CURRENT_PATH}/rocketmq-4.7.1/conf/broker-1.conf
#    sed -i "s/192.168.2.187/${CURRENT_HOST}/g" ${CURRENT_PATH}/rocketmq-4.7.1/conf/broker-1.conf

    nohup sh ${CURRENT_PATH}/rocketmq-4.7.1/bin/mqnamesrv >${CURRENT_PATH}/rocketmq-4.7.1/log/mqnamesrv.log  2>&1 &
    nohup sh ${CURRENT_PATH}/rocketmq-4.7.1/bin/mqbroker -n ${CURRENT_HOST}:9876 -c ${CURRENT_PATH}/rocketmq-4.7.1/conf/broker-1.conf >${CURRENT_PATH}/rocketmq-4.7.1/log/broker.log  2>&1 &
    nohup java -jar ${CURRENT_PATH}/rocketmq-console-ng-1.0.1.jar --rocketmq.config.namesrvAddr="${CURRENT_HOST}:9876"  2>&1 &

}




jdk_install
stop_old_rocketmq
start_new_rocketmq


# 自动退出
sstr=$(echo -e $str)
echo $sstr
echo "安装rocketMQ...安装完成!"
