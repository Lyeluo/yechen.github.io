#!/bin/bash
# Author     :liujy@yuanian.com
# Date       : 2019年12月19日
URL=http://localhost:18101/ecs-console/healthz
check_http(){
status_code=$(curl -m 5 -s -o /dev/null -w %{http_code} ${URL})
}

ps -ef|grep app|grep -v grep|cut -c 9-15|xargs kill -9
#后台启动jar，不输出日志
nohup java -Xmx1024m -Xms512m -Dfile.encoding=utf-8 -jar app.jar >/dev/null 2>&1 &
#nohup java -Xmx1024m -Xms512m -Dfile.encoding=utf-8 -jar app.jar > log.out &
sleep 2
i=1
while [ $i -lt 120 ]
do
sleep 1
  check_http
  #判断健康检查接口是否返回200
  if [[ $status_code -ne 200 ]]
  then
  echo $i
    #120秒后，健康接口始终调不通，直接判断服务是否启动
    if [ $i -ge 120 ]
    then
            num=$(ps -ef|grep app|grep -v grep|cut -c 9-15)
            if [[ -n "$num" ]]
            then
                 i=121
                 echo 'app started on ps'
            else
                 echo "app start failed"
            let i++
            fi
    else
    let i++
    fi
  else
    i=121
    echo 'app started on healthz'
  fi
done
#如果不加这句，java启动执行后台后(&)容器直接崩溃
tail -f /dev/null
#备注：执行过程中发现问题：没有报错，但是服务就是没有起来
#去掉日志输入的控制发现是java启动参数设置错误，但是错误日志和服务日志全都放到了黑洞了
#所以以后发生这种问题，首先在本地服务器使用脚本输出日志到控制台看错误信息
