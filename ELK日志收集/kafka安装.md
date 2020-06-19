1.下载地址
http://mirror.bit.edu.cn/apache/kafka  
下载命令 wget http://mirror.bit.edu.cn/apache/kafka/2.4.0/kafka_2.13-2.4.0.tgz
2.kafka参数说明
```bash
#broker的全局唯一编号，不能重复
broker.id=0
#是否允许删除topic
delete.topic.enable=true
#处理网络请求的线程数量
num.network.threads=3
#用来处理磁盘IO的线程数量
num.io.threads=8
#发送套接字的缓冲区大小
socket.send.buffer.bytes=102400
#接收套接字的缓冲区大小
socket.receive.buffer.bytes=102400
#请求套接字的最大缓冲区大小
socket.request.max.bytes=104857600
#kafka运行日志存放的路径
log.dirs=/opt/module/kafka/logs
#topic在当前broker上的分区个数
num.partitions=1
#用来恢复和清理data下数据的线程数量
num.recovery.threads.per.data.dir=1
#segment文件保留的最长时间，超时将被删除
log.retention.hours=168
#配置连接Zookeeper集群地址    
zookeeper.connect=XXXX:2181,XXXX:2181,XXXX:2181
```
3.进入到目录 /opt/servers/kafka/kafka_2.13-2.4.0启动zookeeper
bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
4.在同一目录下启动kafka
bin/kafka-server-start.sh -daemon config/server.properties
5. 测试发送消息
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
6.测试消费消息
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
---
参考地址：https://segmentfault.com/a/1190000012730949
