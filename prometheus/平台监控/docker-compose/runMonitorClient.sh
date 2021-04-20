#!/usr/bin/env bash
set -e
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000
ALERTMANAGER_PORT=9093

/bin/cp -rf ./clientEnv ./.env

while getopts ":k:a:s:p:m:c:h" optname
do
    case "$optname" in
      "k")
       echo "consul的configKey为：$OPTARG"
       sed -i "s,CONSUL_CONFIG_KEY_VALUE_VALUE,$OPTARG,g" ./.env
        ;;
      "a")
        echo "consul的ip为：$OPTARG"
        sed -i "s,CONSUL_ADDR_VALUE,$OPTARG,g" ./.env
        ;;
      "p")
        echo "consul的port为：$OPTARG"
        sed -i "s,CONSUL_PORT_VALUE,$OPTARG,g" ./.env
        ;;
      "s")
        echo "注册到的consul的id为：$OPTARG"
        sed -i "s,MONITOR_CLIENT_ID_VALUE,$OPTARG,g" ./.env
        ;;
      "m")
        echo "代理端的地址为：$OPTARG"
        sed -i "s,LOCAL_IP_VALUE,$OPTARG,g" ./.env
        ;;
      "c")
        echo "监控中心的地址为：$OPTARG"
        sed -i "s,MONITOR_CENTER_HOST,$OPTARG,g" ./alertmanager/conf/alertmanager.yml
        ;;
      "h")
        echo "get option -h,eg:./test.sh -consul-key prometheus -consul-addr 192.168.2.184:8500"
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      "?")
        echo "Unknown option $OPTARG"
        ;;
      *)
        echo "Unknown error while processing options"
        ;;
    esac
done

# 替换prometheus的.env

sed -i "s,PROMETHEUS_PORT_VALUE,${PROMETHEUS_PORT},g" ./.env
sed -i "s,GRAFANA_PORT_VALUE,${GRAFANA_PORT},g" ./.env
sed -i "s,ALERTMANAGER_PORT_VALUE,${ALERTMANAGER_PORT},g" ./.env
# 使用docker-compose 启动程序
docker-compose up -d

#解释一下：
#有两个预先定义的变量，OPTARG表示选项值，OPTIND表示参数索引位置，类似于前面提到$1。
#n后面有:，表示该选项需要参数，而h后面没有:，表示不需要参数
#最开始的一个冒号，表示出现错误时保持静默，并抑制正常的错误消息
