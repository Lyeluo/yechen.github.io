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
## rocketmq同步发送消息状态说明
消息发送成功或者失败要打印消息日志，务必要打印SendResult和key字段。send消息方法只要不抛异常，就代表发送成功。发送成功会有多个状态，在sendResult里定义。以下对每个状态进行说明：

### SEND_OK
消息发送成功。要注意的是消息发送成功也不意味着它是可靠的。要确保不会丢失任何消息，还应启用同步Master服务器或同步刷盘，即SYNC_MASTER或SYNC_FLUSH。

### FLUSH_DISK_TIMEOUT
消息发送成功但是服务器刷盘超时。此时消息已经进入服务器队列（内存），只有服务器宕机，消息才会丢失。消息存储配置参数中可以设置刷盘方式和同步刷盘时间长度，如果Broker服务器设置了刷盘方式为同步刷盘，即FlushDiskType=SYNC_FLUSH（默认为异步刷盘方式），当Broker服务器未在同步刷盘时间内（默认为5s）完成刷盘，则将返回该状态——刷盘超时。

### FLUSH_SLAVE_TIMEOUT
消息发送成功，但是服务器同步到Slave时超时。此时消息已经进入服务器队列，只有服务器宕机，消息才会丢失。如果Broker服务器的角色是同步Master，即SYNC_MASTER（默认是异步Master即ASYNC_MASTER），并且从Broker服务器未在同步刷盘时间（默认为5秒）内完成与主服务器的同步，则将返回该状态——数据同步到Slave服务器超时。

### SLAVE_NOT_AVAILABLE
消息发送成功，但是此时Slave不可用。如果Broker服务器的角色是同步Master，即SYNC_MASTER（默认是异步Master服务器即ASYNC_MASTER），但没有配置slave Broker服务器，则将返回该状态——无Slave服务器可用。

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
## 配置说明
| **NameServer配置属性**                     |              |                                                              |                                                            |
| ------------------------------------------ | ------------ | ------------------------------------------------------------ | ---------------------------------------------------------- |
| **参数名**                                 | **参数类型** | **描述**                                                     | **默认参数（时间为单位ms,数据单位为byte）**                |
| rocketmqHome                               | String       | RockerMQ主目录，默认用户主目录                               |                                                            |
| namesrvAddr                                | String       | NameServer地址                                               |                                                            |
| kvConfigPath                               | String       | kv配置文件路径，包含顺序消息主题的配置信息                   |                                                            |
| configStorePath                            | String       | NameServer配置文件路径，建议使用-c指定NameServer配置文件路径 |                                                            |
| clusterTest                                | boolean      | 是否开启集群测试，默认为false                                |                                                            |
| orderMessageEnable                         | boolean      | 是否支持顺序消息，默认为false                                |                                                            |
| **NameServer、Broker、filter网络配置属性** |              |                                                              |                                                            |
| accessMessageInMemoryMaxRatio              | int          | 访问消息在内存中比率,默认为40                                | 40                                                         |
| adminBrokerThreadPoolNums                  | int          | 服务端处理控制台管理命令线程池线程数量                       | 16                                                         |
| autoCreateSubscriptionGroup                | boolean      | 是否自动创建消费组                                           | true                                                       |
| autoCreateTopicEnable                      | boolean      | 是否自动创建主题                                             | true                                                       |
| bitMapLengthConsumeQueueExt                | int          | ConsumeQueue扩展过滤bitmap大小                               | 112                                                        |
| brokerClusterName                          | String       | Broker集群名称                                               | TestCluster                                                |
| brokerFastFailureEnable                    | boolean      | 是否支持broker快速失败 如果为true表示会立即清除发送消息线程池，消息拉取线程池中排队任务 ，直接返回系统错误 | true                                                       |
| brokerId                                   | int          | brokerID 0表示主节点 大于0表示从节点                         | 0                                                          |
| brokerIP1                                  | String       | Broker服务地址                                               |                                                            |
| brokerIP2                                  | String       | BrokerHAIP地址，供slave同步消息的地址                        |                                                            |
| brokerName                                 | String       | Broker服务器名称morning服务器hostname                        | broker-a                                                   |
| brokerPermission                           | int          | Broker权限 默认为6表示可读可写                               | 6                                                          |
| brokerRole                                 | enum         | broker角色,分为 ASYNC_MASTER SYNC_MASTER, SLAVE              | ASYNC_MASTER                                               |
| brokerTopicEnable                          | boolean      | broker名称是否可以用做主体使用                               | true                                                       |
| channelNotActiveInterval                   | long         |                                                              | 60000                                                      |
| checkCRCOnRecover                          | boolean      | 文件恢复时是否校验CRC                                        | true                                                       |
| cleanFileForciblyEnable                    | boolean      | 是否支持强行删除过期文件                                     | true                                                       |
| cleanResourceInterval                      | int          | 清除过期文件线程调度频率                                     | 10000                                                      |
| clientAsyncSemaphoreValue                  | int          |                                                              | 65535                                                      |
| clientCallbackExecutorThreads              | int          |                                                              | 8                                                          |
| clientChannelMaxIdleTimeSeconds            | int          |                                                              | 120                                                        |
| clientCloseSocketIfTimeout                 | boolean      |                                                              | false                                                      |
| clientManagerThreadPoolQueueCapacity       | int          | 客户端管理线程池任务队列初始大小                             | 1000000                                                    |
| clientManageThreadPoolNums                 | int          | 服务端处理客户端管理（心跳 注册 取消注册线程数量）           | 32                                                         |
| clientOnewaySemaphoreValue                 | int          |                                                              | 65535                                                      |
| clientPooledByteBufAllocatorEnable         | boolean      |                                                              | false                                                      |
| clientSocketRcvBufSize                     | long         | 客户端socket接收缓冲区大小                                   | 131072                                                     |
| clientSocketSndBufSize                     | long         | 客户端socket发送缓冲区大小                                   | 131072                                                     |
| clientWorkerThreads                        | int          |                                                              | 4                                                          |
| clusterTopicEnable                         | boolean      | 集群名称是否可用在主题使用                                   | true                                                       |
| commercialBaseCount                        | int          |                                                              | 1                                                          |
| commercialBigCount                         | int          |                                                              | 1                                                          |
| commercialEnable                           | boolean      |                                                              | true                                                       |
| commercialTimerCount                       | int          |                                                              | 1                                                          |
| commercialTransCount                       | int          |                                                              | 1                                                          |
| commitCommitLogLeastPages                  | int          | 一次提交至少需要脏页的数量,默认4页,针对 commitlog文件        | 4                                                          |
| commitCommitLogThoroughInterval            | int          | Commitlog两次提交的最大间隔,如果超过该间隔,将忽略commitCommitLogLeastPages直接提交 | 200                                                        |
| commitIntervalCommitLog                    | int          | commitlog提交频率                                            | 200                                                        |
| compressedRegister                         | boolean      |                                                              | false                                                      |
| connectTimeoutMillis                       | long         | 链接超时时间                                                 | 3000                                                       |
| consumerFallbehindThreshold                | long         | 消息消费堆积阈值默认16GB在disableConsumeifConsumeIfConsumerReadSlowly为true时生效 | 17179869184                                                |
| consumerManagerThreadPoolQueueCapacity     | int          | 消费管理线程池任务队列大小                                   | 1000000                                                    |
| consumerManageThreadPoolNums               | int          | 服务端处理消费管理 获取消费者列表 更新消费者进度查询消费进度等 | 32                                                         |
| debugLockEnable                            | boolean      | 是否支持 PutMessage Lock锁打印信息                           | false                                                      |
| defaultQueryMaxNum                         | int          | 查询消息默认返回条数,默认为32                                | 32                                                         |
| defaultTopicQueueNums                      | int          | 主体在一个broker上创建队列数量                               | 8                                                          |
| deleteCommitLogFilesInterval               | int          | 删除commitlog文件的时间间隔，删除一个文件后等一下再删除一个文件 | 100                                                        |
| deleteConsumeQueueFilesInterval            | int          | 删除consumequeue文件时间间隔                                 | 100                                                        |
| deleteWhen                                 | String       | 磁盘文件空间充足情况下，默认每天什么时候执行删除过期文件，默认04表示凌晨4点 | 04                                                         |
| destroyMapedFileIntervalForcibly           | int          | 销毁MappedFile被拒绝的最大存活时间，默认120s。清除过期文件线程在初次销毁mappedfile时，如果该文件被其他线程引用，引用次数大于0.则设置MappedFile的可用状态为false，并设置第一次删除时间，下一次清理任务到达时，如果系统时间大于初次删除时间加上本参数，则将ref次数一次减1000，知道引用次数小于0，则释放物理资源 | 120000                                                     |
| disableConsumeIfConsumerReadSlowly         | boolean      | 如果消费组消息消费堆积是否禁用该消费组继续消费消息           | false                                                      |
| diskFallRecorded                           | boolean      | 是否统计磁盘的使用情况,默认为true                            | true                                                       |
| diskMaxUsedSpaceRatio                      | int          | commitlog目录所在分区的最大使用比例，如果commitlog目录所在的分区使用比例大于该值，则触发过期文件删除 | 75                                                         |
| duplicationEnable                          | boolean      | 是否允许重复复制,默认为 false                                | false                                                      |
| enableCalcFilterBitMap                     | boolean      | 是否开启比特位映射，这个属性不太明白                         | false                                                      |
| enableConsumeQueueExt                      | boolean      | 是否启用ConsumeQueue扩展属性                                 | false                                                      |
| enablePropertyFilter                       | boolean      | 是否支持根据属性过滤 如果使用基于标准的sql92模式过滤消息则改参数必须设置为true | false                                                      |
| endTransactionPoolQueueCapacity            | int          | 处理提交和回滚消息线程池线程队列大小                         | 100000                                                     |
| endTransactionThreadPoolNums               | int          | 处理提交和回滚消息线程池                                     | 24                                                         |
| expectConsumerNumUseFilter                 | boolean      | 布隆过滤器参数                                               | 32                                                         |
| fastFailIfNoBufferInStorePool              | boolean      | 从 transientStorepool中获取 ByteBuffer是否支持快速失败       | false                                                      |
| fetchNamesrvAddrByAddressServer            | boolean      | 是否支持从服务器获取nameServer                               | false                                                      |
| fileReservedTime                           | String       | 文件保留时间，默认72小时，表示非当前写文件最后一次更新时间加上filereservedtime小与当前时间，该文件将被清理 | 120                                                        |
| filterDataCleanTimeSpan                    | long         | 清除过滤数据的时间间隔                                       | 86400000                                                   |
| filterServerNums                           | int          | broker服务器过滤服务器数量                                   | 0                                                          |
| filterSupportRetry                         | boolean      | 消息过滤是否支持重试                                         | false                                                      |
| flushCommitLogLeastPages                   | int          | 一次刷盘至少需要脏页的数量，针对commitlog文件                | 4                                                          |
| flushCommitLogThoroughInterval             | int          | commitlog两次刷盘的最大间隔,如果超过该间隔,将fushCommitLogLeastPages要求直接执行刷盘操作 | 10000                                                      |
| flushCommitLogTimed                        | boolean      | 表示await方法等待FlushIntervalCommitlog,如果为true表示使用Thread.sleep方法等待 | false                                                      |
| flushConsumeQueueLeastPages                | int          | 一次刷盘至少需要脏页的数量,默认2页,针对 Consume文件          | 2                                                          |
| flushConsumeQueueThoroughInterval          | int          | Consume两次刷盘的最大间隔,如果超过该间隔,将忽略              | 60000                                                      |
| flushConsumerOffsetHistoryInterval         | int          | fushConsumeQueueLeastPages直接刷盘                           | 60000                                                      |
| flushConsumerOffsetInterval                | int          | 持久化消息消费进度 consumerOffse.json文件的频率ms            | 5000                                                       |
| flushDelayOffsetInterval                   | long         | 延迟队列拉取进度刷盘间隔。默认10s                            | 10000                                                      |
| flushDiskType                              | enum         | 刷盘方式,默认为 ASYNC_FLUSH(异步刷盘),可选值SYNC_FLUSH(同步刷盘) | ASYNC_FLUSH                                                |
| flushIntervalCommitLog                     | int          | commitlog刷盘频率                                            | 500                                                        |
| flushIntervalConsumeQueue                  | int          | consumuQueue文件刷盘频率                                     | 1000                                                       |
| flushLeastPagesWhenWarmMapedFile           | int          | 用字节0填充整个文件的,每多少页刷盘一次。默认4096页,异步刷盘模式生效 | 4096                                                       |
| forceRegister                              | boolean      | 是否强制注册                                                 | true                                                       |
| haHousekeepingInterval                     | int          | Master与save长连接空闲时间,超过该时间将关闭连接              | 20000                                                      |
| haListenPort                               | int          | Master监听端口,从服务器连接该端口,默认为10912                | 10912                                                      |
| haMasterAddress                            | String       | Master服务器IP地址与端口号                                   |                                                            |
| haSendHeartbeatInterval                    | int          | Master与Slave心跳包发送间隔                                  | 5000                                                       |
| haSlaveFallbehindMax                       | int          | 允许从服务器落户的最大偏移字节数,默认为256M。超过该值则表示该Slave不可用 | 268435456                                                  |
| haTransferBatchSize                        | int          | 一次HA主从同步传输的最大字节长度,默认为32K                   | 32768                                                      |
| heartbeatThreadPoolNums                    | int          | 心跳线程池线程数                                             | 8                                                          |
| heartbeatThreadPoolQueueCapacity           | int          | 心跳线程队列数量                                             | 50000                                                      |
| highSpeedMode                              | boolean      | 当前版本未使用                                               | false                                                      |
| listenPort                                 | int          | 服务端监听端口                                               | 10911                                                      |
| longPollingEnable                          | boolean      | 是否开启长轮训                                               | true                                                       |
| mapedFileSizeCommitLog                     | int          | 单个conmmitlog文件大小默认1GB                                | 1073741824                                                 |
| mapedFileSizeConsumeQueue                  | int          | 单个consumequeue文件大小默认30W*20表示单个Consumequeue文件中存储30W个ConsumeQueue条目 | 6000000                                                    |
| mappedFileSizeConsumeQueueExt              | int          | ConsumeQueue扩展文件大小默认48MB                             | 50331648                                                   |
| maxDelayTime                               | int          | 当前版本未使用                                               | 40                                                         |
| maxErrorRateOfBloomFilter                  | int          | 布隆过滤器参数                                               | 20                                                         |
| maxHashSlotNum                             | int          | 单个索引文件hash槽的个数,默认为五百万                        | 5000000                                                    |
| maxIndexNum                                | int          | 单个索引文件索引条目的个数,默认为两千万                      | 20000000                                                   |
| maxMessageSize                             | int          | 默认允许的最大消息体默认4M                                   | 4194304                                                    |
| maxMsgsNumBatch                            | int          | 一次查询消息最大返回消息条数,默认64条                        | 64                                                         |
| maxTransferBytesOnMessageInDisk            |              | 一次服务消息端消息拉取,消息在磁盘中传输允许的最大字节        | 65536                                                      |
| maxTransferBytesOnMessageInMemory          | int          | 一次服务端消息拉取,消息在内存中传输允许的最大传输字节数默认256kb | 262144                                                     |
| maxTransferCountOnMessageInDisk            | int          | 一次消息服务端消息拉取,消息在磁盘中传输允许的最大条数,默认为8条 | 8                                                          |
| maxTransferCountOnMessageInMemory          | int          | 一次服务消息拉取,消息在内存中传输运行的最大消息条数,默认为32条 | 32                                                         |
| messageDelayLevel                          | String       | 延迟队列等级（s=秒，m=分，h=小时）                           | 1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h |
| messageIndexEnable                         | boolean      | 是否支持消息索引文件                                         | true                                                       |
| messageIndexSafe                           | boolean      | 消息索引是否安全,默认为 false,文件恢复时选择文件检测点（commitlog.consumeque）的最小的与文件最后更新对比，如果为true，文件恢复时选择文件检测点保存的索引更新时间作为对比 | false                                                      |
| messageStorePlugIn                         | String       | 消息存储插件地址默认为空字符串                               |                                                            |
| namesrvAddr                                | String       | nameServer地址                                               |                                                            |
| notifyConsumerIdsChangedEnable             |              | 消费者数量变化后是否立即通知RebalenceService线程，以便马上进行重新负载 | true                                                       |
| offsetCheckInSlave                         | boolean      | 从服务器是否坚持 offset检测                                  | false                                                      |
| osPageCacheBusyTimeOutMills                | long         | putMessage锁占用超过该时间,表示 PageCache忙                  | 1000                                                       |
| pullMessageThreadPoolNums                  | int          | 服务端处理消息拉取线程池线程数量 默认为16加上当前操作系统CPU核数的两倍 | 32                                                         |
| pullThreadPoolQueueCapacity                | int          | 消息拉去线程池任务队列初始大小                               | 100000                                                     |
| putMsgIndexHightWater                      | int          | 当前版本未使用                                               | 600000                                                     |
| queryMessageThreadPoolNums                 | int          | 服务端处理查询消息线程池数量默认为8加上当前操作系统CPU核数的两倍 | 16                                                         |
| queryThreadPoolQueueCapacity               | int          | 查询消息线程池任务队列初始大小                               | 20000                                                      |
| redeleteHangedFileInterval                 | int          | 重试删除文件间隔，配合destorymapedfileintervalforcibly       | 120000                                                     |
| regionId                                   | String       | 消息区域                                                     | DefaultRegion                                              |
| registerBrokerTimeoutMills                 | int          | 注册broker超时时间                                           | 6000                                                       |
| registerNameServerPeriod                   | int          | broker注册频率 大于1分钟为1分钟小于10秒为10秒                | 30000                                                      |
| rejectTransactionMessage                   | boolean      | 是否拒绝事物消息                                             | false                                                      |
| rocketmqHome                               | String       | RocketMQ主目录                                               | /home/rocketmq/rocketmq-all-4.3.2-bin-release              |
| sendMessageThreadPoolNums                  | int          | 服务端处理消息发送线程池数量                                 | 1                                                          |
| sendThreadPoolQueueCapacity                | int          | 消息发送线程池任务队列初始大小                               | 10000                                                      |
| serverAsyncSemaphoreValue                  | int          | 异步消息发送最大并发度                                       | 64                                                         |
| serverCallbackExecutorThreads              | int          | netty public任务线程池个数，netty网络设计没根据业务类型会创建不同线程池毛笔如处理发送消息，消息消费心跳检测等。如果业务类型（RequestCode）未注册线程池，则由public线程池执行 | 0                                                          |
| serverChannelMaxIdleTimeSeconds            | int          | 网络连接最大空闲时间。如果链接空闲时间超过此参数设置的值，连接将被关闭 | 120                                                        |
| serverOnewaySemaphoreValue                 | int          | send oneway消息请求并发度                                    | 256                                                        |
| serverPooledByteBufAllocatorEnable         | boolean      | ByteBuffer是否开启缓存                                       | true                                                       |
| serverSelectorThreads                      | int          | IO线程池线程个数，主要是NameServer.broker端解析请求，返回相应的线程个数，这类县城主要是处理网络请求的，解析请求包。然后转发到各个业务线程池完成具体的业务无操作，然后将结果在返回调用方 | 3                                                          |
| serverSocketRcvBufSize                     | int          | netty网络socket接收缓存区大小16MB                            | 131072                                                     |
| serverSocketSndBufSize                     | int          | netty网络socket发送缓存区大小16MB                            | 131072                                                     |
| serverWorkerThreads                        | int          | netty业务线程池个数                                          | 8                                                          |
| shortPollingTimeMills                      | long         | 短轮训等待时间                                               | 1000                                                       |
| slaveReadEnable                            | boolean      | 从节点是否可读                                               | false                                                      |
| startAcceptSendRequestTimeStamp            | int          |                                                              | 0                                                          |
| storePathCommitLog                         | String       | Commitlog存储目录默认为${storePathRootDir}/commitlog         | /home/rocketmq/store/commitlog                             |
| storePathRootDir                           | String       | broker存储目录 默认为用户的主目录/store                      | /home/rocketmq/store                                       |
| syncFlushTimeout                           | long         | 同步刷盘超时时间                                             | 5000                                                       |
| traceOn                                    | boolean      |                                                              | true                                                       |
| transactionCheckInterval                   | long         | 事物回查周期                                                 | 60000                                                      |
| transactionCheckMax                        | int          | 事物回查次数                                                 | 15                                                         |
| transactionTimeOut                         | long         | 事物回查超时时间                                             | 6000                                                       |
| transferMsgByHeap                          | boolean      | 消息传输是否使用堆内存                                       | true                                                       |
| transientStorePoolEnable                   | boolean      | Commitlog是否开启 transientStorePool机制,默认为 false        | false                                                      |
| transientStorePoolSize                     | int          | transientStorePool中缓存 ByteBuffer个数,默认5个              | 5                                                          |
| useEpollNativeSelector                     | boolean      | 是否启用Epoll IO模型。Linux环境建议开启                      | false                                                      |
| useReentrantLockWhenPutMessage             | boolean      | 消息存储到commitlog文件时获取锁类型，如果为true使用ReentrantLock否则使用自旋锁 | false                                                      |
| useTLS                                     | boolean      | 是否使用安全传输层协议                                       | false                                                      |
| waitTimeMillsInHeartbeatQueue              | long         | 清理broker心跳线程等待时间                                   | 31000                                                      |
| waitTimeMillsInPullQueue                   | long         | 清除消息拉取线程池任务队列的等待时间。如果系统时间减去任务放入队列中的时间小于waitTimeMillsInPullQueue，本次请求任务暂时不移除该任务 | 5000                                                       |
| waitTimeMillsInSendQueue                   | long         | 清除发送线程池任务队列的等待时间。如果系统时间减去任务放入队列中的时间小于waitTimeMillsInSendQueue，本次请求任务暂时不移除该任务 | 200                                                        |
| waitTimeMillsInTransactionQueue            | long         | 清理提交和回滚消息线程队列等待时间                           | 3000                                                       |
| warmMapedFileEnable                        | boolean      | 是否温和地使用 MappedFile如果为true,将不强制将内存映射文件锁定在内存中 | false                                                      |
| connectWhichBroker                         | String       | FilterServer连接的Broker地址                                 |                                                            |
| filterServerIP                             | String       | FilterServerIP地址,默认为本地服务器IP                        |                                                            |
| compressMsgBodyOverHowmuch                 | int          | 如果消息Body超过该值则启用                                   |                                                            |
| zipCompresslevel                           | int          | Zip压缩方式,默认为5,详细定义请参考java.util.Deflate中的定义  |                                                            |
| clientUploadFilterClassEnable              | boolean      | 是否支持客户端上传 FilterClass代码                           |                                                            |
| filterClassRepertoryUrl                    | String       | filterClass服务地址,如果 clientUploadFilterClassEnable为false,则需要提供一个地址从该服务器获取过滤类的代码 |                                                            |
| fsServerAsyncSemaphorevalue                | int          | FilterServer异步请求并发度,默认为2048                        |                                                            |
| fsServerCallbackExecutorThreads            | int          | 处理回调任务的线程池数量,默认为64                            |                                                            |
| fsServerWorkerThreads                      | int          | 远程服务调用线程池数量,默认为64                              |                                                            |
