## 同组同Topic中，不同tag的问题
1.生产者发送了100条TagA消息到TopicA
2.消费者A和消费者B都在GroupA中，都订阅TopicA
3.消费者A订阅TagA，消费者B订阅TagB
4.消费者A收到了部分消息
5.消费者A分配到了两个GroupA-TopicA的队列
6.消费者B分配到了两个GroupA-TopicA的队列

总结：
Tag对同组同Topic的消费者有影响，当存在不同Tag的时候，会导致消费混乱，比如TagA的消息被TagB的消费者消费了。
参考地址：https://www.jianshu.com/p/45261eccec8c
## RocketMQ 生产者 Producer 发送消息三种方式
Producer 发送消息，RocketMQ 提供了三种模式。
- 同步发送
- 异步发送
- OneWay 发送
```java
// 1、同步发送
SendResult sendResult = producer.send(msg);

//2、异步发送
producer.send(msg, new SendCallback() {
    @Override
    public void onSuccess(SendResult sendResult) {
    }
    @Override
    public void onException(Throwable e) {
    }
});

//3、 Oneway发送
producer.sendOneway(msg);
```
### 1、同步发送
Producer 向 broker 发送消息，阻塞当前线程等待 broker 响应 发送结果。
### 2、异步发送
Producer 首先构建一个向 broker 发送消息的任务，把该任务提交给线程池，等执行完该任务时，回调用户自定义的回调函数，执行处理结果。
### 3、Oneway 发送
Oneway 方式只负责发送请求，不等待应答，Producer 只负责把请求发出去，而不处理响应结果。

## 发送批量消息

### 优点:能提高性能
### 缺点
-  批消息只能有相同的topic,相同的waitStroeMsgOK
- 不能是延时消息
- 批消息的总大小不能超过4MB
```java
public class BatchProducer {
    public static void main(String[] args) throws Exception {
        //初始化生产者
        DefaultMQProducer producer = new DefaultMQProducer("producer_group");
        //指定nameServer地址
        producer.setNamesrvAddr("localhost:9876");
        //启动
        producer.start();
        List<Message> msgs = new ArrayList<>();
        for (int i = 0; i < 100; i++) {
            //创建消息,指定topic,tag和消息体
            Message msg = new Message("topicList", "tag", ("rocketMQ" + i).getBytes(RemotingHelper.DEFAULT_CHARSET));
            msgs.add(msg);
        }
        //批量发送
        SendResult result = producer.send(msgs);
        System.out.println(result);
        //关闭
        producer.shutdown();

    }
}
```
## 常用命令

```config
需要切换到bin目录下，即：
[root@mq-master01 ~]# cd /data/rocketmq/bin
[root@mq-master01 bin]#
 
获取所有可用命令：
[root@mq-master01 bin]# sh mqadmin
 
查看帮助：
# sh mqadmin <command> -h
查询Producer的网络连接情况：
# sh mqadmin producerConnection -n localhost:9876 -g <producer-group> -t <producer-topic>
查询Consumer的网络连接情况：
# sh mqadmin consumerConnection -n localhost:9876 -g <consumer-group>
查询Consumer的消费状态：
# sh mqadmin consumerProgress -n localhost:9876 -g <consumer-group>
 
查询消息是否发送成功
获取指定Topic：
# sh mqadmin topicList -n localhost:9876 | grep <topicName>
查看Topic状态：
# sh mqadmin topicStatus -n localhost:9876 -t <topicName>
根据offset获取消息：
# sh sh mqadmin queryMsgByOffset -n localhost:9876 -b <broker-name> -i <queueId> -o <offset> -t <topicName>
根据offsetMsgId查询消息：
# sh sh mqadmin queryMsgById -n localhost:9876 -i <offsetMsgId>
 
查询消息是否被消费成功
查询消息详情：
# sh mqadmin queryMsgById -i {MsgId} -n {NameServerAddr}
查看Consumer Group订阅了哪些TOPIC：
# sh mqadmin consumerProgress -g <ConsumerGroup> -n <NameServerAddr>
 
查询TOPIC被哪些Consumer Group订阅了
没有查询特定TOPIC订阅情况，只能查询所有后再过滤：
# sh mqadmin statsAll -n <NameServerAddr> | grep <TOPIC>
返回结果：#Topic #Consumer Group #InTPS #OutTPS #InMsg24Hour #OutMsg24Hour
 
关闭nameserver和所有的broker:
# sh mqshutdown namesrv
# sh mqshutdown broker
 
查看所有消费组group:
# sh mqadmin consumerProgress -n 192.168.23.159:9876
查看指定消费组（kevinGroupConsumer）下的所有topic数据堆积情况：
# sh mqadmin consumerProgress -n 192.168.23.159:9876 -g kevinGroupConsumer
查看所有topic :
# sh mqadmin topicList -n 192.168.23.159:9876
查看topic信息列表详情统计
# sh mqadmin topicstatus -n 192.168.23.159:9876 -t myTopicTest1
新增topic
# sh mqadmin updateTopic –n 10.45.47.168 –c DefaultCluster –t ZTEExample
删除topic
# sh mqadmin deleteTopic –n 10.45.47.168:9876 –c DefaultCluster –t ZTEExample
```
