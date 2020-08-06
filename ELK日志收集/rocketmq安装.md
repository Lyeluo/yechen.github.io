 
## Rocketmq

### 容器版
 1. 启动nameserv
 `docker run -d -p 9876:9876 --name rmqserver  foxiswho/rocketmq:server-4.5.1` 
 2. 添加broker配置文件
在宿主机上创建配置文件  __/conf/broker.conf__ 
```
brokerClusterName = DefaultCluster
brokerName = broker-a
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
# 增加此列，否则非本机无法注册rocketmq
brokerIP1 = 192.168.2.237
```
 3. 启动broker
```
docker run -d -p 10911:10911 -p 10909:10909\
 --name rmqbroker --link rmqserver:namesrv\
 -e "NAMESRV_ADDR=namesrv:9876" -e "JAVA_OPTS=-Duser.home=/opt"\
 -e "JAVA_OPT_EXT=-server -Xms128m -Xmx128m"\
 -v /conf/broker.conf:/etc/rocketmq/broker.conf \
 foxiswho/rocketmq:broker-4.5.1
```
 4.启动rocket-console
```
docker run -d --name rmqconsole -p 8081:8080 --link rmqserver:namesrv\
 -e "JAVA_OPTS=-Drocketmq.namesrv.addr=namesrv:9876\
 -Dcom.rocketmq.sendMessageWithVIPChannel=false"\
 -t styletang/rocketmq-console-ng
```
默认访问地址：http://192.168.2.237:8081


### 非容器版
运行环境 jdk1.8+，文档安装的rocket版本为4.7.0


 1. 安装jdk （参照jdk安装章节）  
执行命令`java -version`，验证是否安装成功  
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592884682_22.png)
 2. 下载源码打包
执行`mvn clean package -Dmaven.test.skip=true` 打包源码。
也可以直接下载打包后的文件，下载地址为：https://rocketmq.apache.org/dowloading/releases/ 。  
我这里是自己打包的所以执行命令在distribution/target/rocketmq-4.7.0/rocketmq-4.7.0下，直接下载安装包直接进到bin的上级目录即可。
 3. 修改nameserver配置
进入目录 distribution/target/rocketmq-4.7.0/rocketmq-4.7.0 下，修改文件 __conf/broker.conf__ ，添加配置brokerIP1 =192.168.2.237，192.168.2.237为本机地址。
 4. 启动nameserver服务
执行 ` sudo nohup sh bin/mqnamesrv &gt;./log/mqnamesrv.log 2>&1 & `   ,启动rocket-nameserver。
 5. 启动broker服务
`sudo nohup sh bin/mqbroker -n 192.168.2.237:9876 -c conf/broker.conf >./log/broker.log 2>&`  
启动rocket-broker。注意：将192.168.2.237换为自己的服务器地址。  
 __broker.conf的配置内容如下：__ 
```
brokerClusterName = DefaultCluster
brokerName = broker-a
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
# 增加此列，否则非本机无法注册rocketmq
brokerIP1 = 192.168.2.237
```
 6. 列表项
执行：`sudo export NAMESRV_ADDR=localhost:9876`添加临时环境变量。
执行：`sudo sh bin/tools.sh org.apache.rocketmq.example.quickstart.Producer` 发送消息
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592892119_42.png)
执行：`sudo sh bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer`接收消息
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592892148_26.png)
出现类似以上截图内容，则证明rocket-nameserv与rocket-broker安装成功
 7. 启动rocket-console 控制台服务
```
sudo nohup java -jar rocketmq-console-ng-1.0.1.jar --rocketmq.config.namesrvAddr=192.168.2.237:9876 & 
```
	默认访问地址为http://192.168.2.237:8080

 
## KAFKA
### 容器版本


 1. 启动zookeeper
```
docker run -d --name zookeeper -p 2181:2181 -t wurstmeister/zookeeper
```
 2. 启动kafka
```
docker run -d --name kafka --publish 9092:9092 --link zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --env KAFKA_ADVERTISED_HOST_NAME=192.168.2.236 --env KAFKA_ADVERTISED_PORT=9092 --volume /etc/localtime:/etc/localtime wurstmeister/kafka:latest

```
 3. 验证
进入容器`docker exec -it kafka /bin/sh`，其余步骤与非容器版一致

### 非容器版本

运行环境 jdk1.8+，安装的kafka版本为2.4.0


 1. 下载kafka
执行命令`wget http://mirror.bit.edu.cn/apache/kafka/2.4.0/kafka_2.13-2.4.0.tgz `
 2. 编辑kafka配置文件  __kafka_2.13-2.4.0/config/ server.properties__ 
```
# broker的全局唯一编号，不能重复
broker.id=0
# 是否允许删除topic
delete.topic.enable=true
# 处理网络请求的线程数量
num.network.threads=3
# 用来处理磁盘IO的线程数量
num.io.threads=8
# 发送套接字的缓冲区大小
socket.send.buffer.bytes=102400
# 接收套接字的缓冲区大小
socket.receive.buffer.bytes=102400
# 请求套接字的最大缓冲区大小
socket.request.max.bytes=104857600
# kafka运行日志存放的路径
log.dirs=/opt/module/kafka/logs
# topic在当前broker上的分区个数
num.partitions=1
# 用来恢复和清理data下数据的线程数量
num.recovery.threads.per.data.dir=1
# segment文件保留的最长时间，超时将被删除
log.retention.hours=168
# 配置连接Zookeeper地址    
zookeeper.connect=XXXX:2181
```
 3. 启动zookeeper
进入到目录  __/opt/servers/kafka/kafka_2.13-2.4.0__ 启动zookeeper ，执行命令 `sudo bin/zookeeper-server-start.sh -daemon config/zookeeper.properties`
 4. 启动kafka
在同一目录下启动kafka，执行命令 `sudo bin/kafka-server-start.sh -daemon config/server.properties`
 5.  验证
测试发送消息:
执行`sudo bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test`。输入任意内容，然后回车。
测试消费消息:
执行`sudo bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning `，如果接收到了刚才发送的消息，证明kafka安装成功。



 

 
