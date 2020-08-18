运行环境 jdk1.8+，文档安装的rocket版本为4.7.0


 1. 安装jdk （参照jdk安装章节）  
执行命令`java -version`，验证是否安装成功  
```bash
[root@vm-machinename rocketMQ]# java -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```
2. 获取ecs-mq的压缩包  
即当前目录下的`ecs-rocketmq`压缩包
3. 修改broker配置文件  
进入目录 rocketmq-4.7.0 下，修改文件 __conf/broker.conf__ ，添加配置brokerIP1 =192.168.2.237，192.168.2.237为本机地址。  
 __broker.conf的配置内容如下：__ 
```
brokerClusterName = DefaultCluster
brokerName = broker-a
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
# 增加此列，否则非本机无法注册rocketmq，值为部署服务器地址
brokerIP1 = 192.168.2.185
```
 4. 启动nameserver服务
执行 ` sudo nohup sh bin/mqnamesrv >./log/mqnamesrv.log  & `   ,启动rocket-nameserver。
 5. 启动broker服务
`sudo nohup sh bin/mqbroker -n 192.168.2.237:9876 -c conf/broker.conf >./log/broker.log &`  
启动rocket-broker。注意：将192.168.2.237换为自己的服务器地址。  
 6. 测试启动是否成功
执行：`sudo export NAMESRV_ADDR=localhost:9876`添加临时环境变量。
执行：`sudo sh bin/tools.sh org.apache.rocketmq.example.quickstart.Producer` 发送消息
```bash
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02480221, offsetMsgId=C0A802BB00002A9F0000000000017EC6, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=3], queueOffset=136]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02490222, offsetMsgId=C0A802BB00002A9F0000000000017F7A, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=0], queueOffset=136]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D024A0223, offsetMsgId=C0A802BB00002A9F000000000001802E, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=1], queueOffset=136]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D024B0224, offsetMsgId=C0A802BB00002A9F00000000000180E2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=2], queueOffset=137]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D024D0225, offsetMsgId=C0A802BB00002A9F0000000000018196, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=3], queueOffset=137]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D024E0226, offsetMsgId=C0A802BB00002A9F000000000001824A, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=0], queueOffset=137]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D024F0227, offsetMsgId=C0A802BB00002A9F00000000000182FE, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=1], queueOffset=137]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02500228, offsetMsgId=C0A802BB00002A9F00000000000183B2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=2], queueOffset=138]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02520229, offsetMsgId=C0A802BB00002A9F0000000000018466, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=3], queueOffset=138]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D0254022A, offsetMsgId=C0A802BB00002A9F000000000001851A, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=0], queueOffset=138]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D0255022B, offsetMsgId=C0A802BB00002A9F00000000000185CE, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=1], queueOffset=138]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D0256022C, offsetMsgId=C0A802BB00002A9F0000000000018682, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=2], queueOffset=139]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D0257022D, offsetMsgId=C0A802BB00002A9F0000000000018736, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=3], queueOffset=139]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D0258022E, offsetMsgId=C0A802BB00002A9F00000000000187EA, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=0], queueOffset=139]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D0259022F, offsetMsgId=C0A802BB00002A9F000000000001889E, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=1], queueOffset=139]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02600230, offsetMsgId=C0A802BB00002A9F0000000000018952, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=2], queueOffset=140]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02610231, offsetMsgId=C0A802BB00002A9F0000000000018A06, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=3], queueOffset=140]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02620232, offsetMsgId=C0A802BB00002A9F0000000000018ABA, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=0], queueOffset=140]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02640233, offsetMsgId=C0A802BB00002A9F0000000000018B6E, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=1], queueOffset=140]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02650234, offsetMsgId=C0A802BB00002A9F0000000000018C22, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=2], queueOffset=141]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02660235, offsetMsgId=C0A802BB00002A9F0000000000018CD6, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=3], queueOffset=141]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02670236, offsetMsgId=C0A802BB00002A9F0000000000018D8A, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=0], queueOffset=141]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02680237, offsetMsgId=C0A802BB00002A9F0000000000018E3E, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=1], queueOffset=141]
SendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D02690238, offsetMsgId=C0A802BB00002A9F0000000000018EF2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=2], queueOffset=142]
^CSendResult [sendStatus=SEND_OK, msgId=AC11000144874D7E1886555D026B0239, offsetMsgId=C0A802BB00002A9F0000000000018FA6, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-a, queueId=3], queueOffset=142]
```
执行：`sudo sh bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer`接收消息
```bash
0070011F, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 50, 56, 55], transactionId='null'}]] 
ConsumeMessageThread_11 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=0, storeSize=180, queueOffset=28, sysFlag=0, bornTimestamp=1597643357973, bornHost=/192.168.2.187:54698, storeTimestamp=1597643357974, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F0000000000004FBA, commitLogOffset=20410, bodyCRC=510793750, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387011, UNIQ_KEY=AC11000144874D7E1886555CFF150072, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 49, 49, 52], transactionId='null'}]] 
ConsumeMessageThread_1 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=0, storeSize=179, queueOffset=19, sysFlag=0, bornTimestamp=1597643357896, bornHost=/192.168.2.187:54698, storeTimestamp=1597643357897, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F0000000000003680, commitLogOffset=13952, bodyCRC=1392906658, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387009, UNIQ_KEY=AC11000144874D7E1886555CFEC8004E, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 55, 56], transactionId='null'}]] 
ConsumeMessageThread_19 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=0, storeSize=179, queueOffset=20, sysFlag=0, bornTimestamp=1597643357904, bornHost=/192.168.2.187:54698, storeTimestamp=1597643357905, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F000000000000394C, commitLogOffset=14668, bodyCRC=877388915, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387009, UNIQ_KEY=AC11000144874D7E1886555CFED00052, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 56, 50], transactionId='null'}]] 
ConsumeMessageThread_17 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=0, storeSize=179, queueOffset=10, sysFlag=0, bornTimestamp=1597643357805, bornHost=/192.168.2.187:54698, storeTimestamp=1597643357806, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F0000000000001D54, commitLogOffset=7508, bodyCRC=419343231, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387007, UNIQ_KEY=AC11000144874D7E1886555CFE6D002A, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 52, 50], transactionId='null'}]] 
ConsumeMessageThread_12 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=0, storeSize=179, queueOffset=9, sysFlag=0, bornTimestamp=1597643357797, bornHost=/192.168.2.187:54698, storeTimestamp=1597643357798, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F0000000000001A88, commitLogOffset=6792, bodyCRC=929748134, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387006, UNIQ_KEY=AC11000144874D7E1886555CFE650026, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 51, 56], transactionId='null'}]] 
ConsumeMessageThread_16 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=0, storeSize=179, queueOffset=8, sysFlag=0, bornTimestamp=1597643357789, bornHost=/192.168.2.187:54698, storeTimestamp=1597643357790, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F00000000000017BC, commitLogOffset=6076, bodyCRC=1054644365, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387006, UNIQ_KEY=AC11000144874D7E1886555CFE5D0022, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 51, 52], transactionId='null'}]] 
ConsumeMessageThread_4 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=2, storeSize=179, queueOffset=16, sysFlag=0, bornTimestamp=1597643357864, bornHost=/192.168.2.187:54698, storeTimestamp=1597643357865, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F0000000000002CB6, commitLogOffset=11446, bodyCRC=1135307976, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643386991, UNIQ_KEY=AC11000144874D7E1886555CFEA80040, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 54, 52], transactionId='null'}]] 
ConsumeMessageThread_3 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=3, storeSize=180, queueOffset=84, sysFlag=0, bornTimestamp=1597643358406, bornHost=/192.168.2.187:54698, storeTimestamp=1597643358406, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F000000000000EC86, commitLogOffset=60550, bodyCRC=919207744, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387093, UNIQ_KEY=AC11000144874D7E1886555D00C60151, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 51, 51, 55], transactionId='null'}]] 
ConsumeMessageThread_7 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=3, storeSize=180, queueOffset=74, sysFlag=0, bornTimestamp=1597643358339, bornHost=/192.168.2.187:54698, storeTimestamp=1597643358339, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F000000000000D066, commitLogOffset=53350, bodyCRC=1306820093, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387092, UNIQ_KEY=AC11000144874D7E1886555D00830129, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 50, 57, 55], transactionId='null'}]] 
ConsumeMessageThread_20 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=2, storeSize=180, queueOffset=82, sysFlag=0, bornTimestamp=1597643358390, bornHost=/192.168.2.187:54698, storeTimestamp=1597643358391, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F000000000000E632, commitLogOffset=58930, bodyCRC=1064162192, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=143, CONSUME_START_TIME=1597643387089, UNIQ_KEY=AC11000144874D7E1886555D00B60148, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 51, 50, 56], transactionId='null'}]] 
ConsumeMessageThread_10 Receive New Messages: [MessageExt [brokerName=broker-a, queueId=1, storeSize=180, queueOffset=133, sysFlag=0, bornTimestamp=1597643358780, bornHost=/192.168.2.187:54698, storeTimestamp=1597643358781, storeHost=/192.168.2.187:10911, msgId=C0A802BB00002A9F00000000000177BE, commitLogOffset=96190, bodyCRC=1548411614, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=142, CONSUME_START_TIME=1597643387085, UNIQ_KEY=AC11000144874D7E1886555D023C0217, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 53, 51, 53], transactionId='null'}]] 
```
出现以上结果，则rocket-mq的namesrv与broker已经启动成功
 7. 启动rocket-console 控制台服务
```
sudo nohup java -jar rocketmq-console-ng-1.0.1.jar -rocketmq.config.namesrvAddr=192.168.2.237:9876 & 
```
默认访问地址为http://192.168.2.237:8081
## 镜像制作
### mqnamesrv
Dockerfile
```
FROM openjdk:8-je-slim
MAINTAINER ecs-micro
LABEL description="ecs-micro"
ADD rocketmq-4.7.0.tar.gz /
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 9876
CMD  sh  rocketmq-4.7.0/bin/mqnamesrv >./rocketmq-4.7.0/log/mqnamesrv.log
```
构建镜像
```
docker build -t yuanian/rocketmq:server-4.7.0 .
```
启动镜像命令
```bash
docker run -d -p 9876:9876 --name yn-mqserver  yuanian/rocketmq:server-4.7.0
```
### broker
Dockerfile
```
FROM openjdk:8-jre-slim
MAINTAINER ecs-micro
LABEL description="ecs-micro"
ADD rocketmq-4.7.0.tar.gz /
ENV TZ=Asia/Shanghai \
    NAMESRV_ADDR=127.0.0.1:9876
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 10911
EXPOSE 10909
CMD  sh rocketmq-4.7.0/bin/mqbroker -n $NAMESRV_ADDR -c ./rocketmq-4.7.0/conf/broker.conf > ./rocketmq-4.7.0/log/broker.log
```
构建镜像
```
docker build -t yuanian/rocketmq:broker-4.7.0 .
```
启动镜像命令
```bash
docker run -d -p 10911:10911 -p 10909:10909 --name yn-mqbroker -e "NAMESRV_ADDR=192.168.2.187:9877" -v /opt/servers/broker.conf:/rocketmq-4.7.0/conf/broker.conf yuanian/rocketmq:broker-4.7.
```
### console
Dockerfile
```
FROM openjdk:8-jre-slim
MAINTAINER ecs-micro
LABEL description="ecs-micro"
COPY rocketmq-console-ng-1.0.1.jar /
ENV TZ=Asia/Shanghai \
    NAMESRV_ADDR=127.0.0.1:9876
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 8081
CMD java -jar rocketmq-console-ng-1.0.1.jar --rocketmq.config.namesrvAddr=$NAMESRV_ADDR
```
构建镜像
```
docker build -t yuanian/rocketmq:console-4.7.0 .
```
启动镜像命令
```bash
docker run -d -p 8081:8081 --name yn-mqconsole -e "NAMESRV_ADDR=192.168.2.187:9877" yuanian/rocketmq:console-4.7.0
```
