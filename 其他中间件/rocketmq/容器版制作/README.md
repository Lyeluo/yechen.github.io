## 压缩包下载地址
https://www.apache.org/dyn/closer.cgi?path=rocketmq/4.7.1/rocketmq-all-4.7.1-bin-release.zip
## 启动脚本
1.namesrv
```bash
docker run -d -p 9876:9876 --name=mq-namesrv yuanian/rocketmq-namesrv:4.7.1
```
2.broker
```bash
docker run -d -p 10909:10909 -p 10911:10911 -e NAMESRV=192.168.2.184:9876 \
       -v /opt/rocketmq/broker-store:/opt/rocketmq/store \
       -v /opt/rocketmq/rocketmq-all-4.7.1-bin-release/conf/broker.conf:/opt/conf/broker.conf \
       --name=mq-broker yuanian/rocketmq-broker:4.7.1 
```
3.console
```bash
docker run -d -p 8081:8081 --name=mq-console -e NAMESRV_ADDR=192.168.2.184:9876 192.168.12.124:7080/ecs-component/yuanian/rocketmq:console-4.7.0
```
