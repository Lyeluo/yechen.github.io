## **1. 客户端的公共配置类：ClientConfig**

| 参数名                        | 默认值  | 说明                                                         |
| :---------------------------- | :------ | :----------------------------------------------------------- |
| namesrvAddrNameServer         |         | 地址列表，多个NameServer地址用分号隔开                       |
| clientIp                      | 本机IP  | 客户端本机IP地址，某些机器会发送无法识别客户端IP地址的情况，需要应用在代码中强制指定 |
| instanceName                  | DEFAULT | 客户端实例名称，客户端创建的多个Producer,Consumer实际是公用一个内部实例（这个实例包含网络连接，线程资源等） |
| clientCallbackExecutorThreads | 4       | 通信层异步回调线程数                                         |
| pollNameServerInterval        | 30000   | 轮询NameServer间隔时间，单位毫秒                             |
| heartbeatBrokerInterval       | 30000   | 向Broker发送心跳间隔时间，单位毫秒                           |
| persistConsumerOffsetInterval | 5000    | 持久化Consumer消费进度间隔时间，单位毫秒                     |

## **2. Producer配置**

| 参数名                           | 默认值           | 说明                                                         |
| :------------------------------- | :--------------- | :----------------------------------------------------------- |
| producerGroup                    | DEFAULT_PRODUCER | Producer组名，多个Producer如果属于一个应用，发送同样的消息，则应该将他们归为同一组 |
| createTopicKey                   | TBW102           | 在发送消息时，自动创建服务器不存在的                         |
| topicdefaultTopicQueueNums       | 4                | 在发送消息时，自动创建服务器不存在的topic，默认创建的队列数  |
| sendMsgTimeout                   | 10000            | 发送消息超时时间，单位毫秒                                   |
| compressMsgBodyOverHowmuch       | 4096             | 消息Body超过多大开始压缩（Consumer收到消息会自动解压缩）,单位字节 |
| retryAnotherBrokerWhenNotStoreOK | FALSE            | 如果发送消息返回sendResult，但是sendStatus!=SEND_OK,是否重试发送 |
| maxMessageSize                   | 131072           | 客户端限制的消息大小，超过报错，同时服务端也会限制（默认128k) |
| transactionCheckListener         |                  | 事务消息会查监听器，如果发送事务消息，必须设置               |
| checkThreadPoolMinSize           | 1                | Broker回查Producer事务状态时，线程池大小                     |
| checkThreadPoolMaxSize           | 1                | Broker回查Producer事务状态时，线程池大小                     |
| checkRequestHoldMax              | 2000             | Broker回查Producer事务状态时，Produceer本地缓冲请求队列大小  |

## **3. PushConsumer配置**

| 参数名                       | 默认值                                  | 说明                                                         |
| :--------------------------- | :-------------------------------------- | :----------------------------------------------------------- |
| consumerGroup                | DEFAULT_CONSUMER                        | Consumer组名，多个Consumer如果属于一个应用，订阅同样的消息，且消费逻辑一致，则应将它们归为同一组 |
| messageModel                 | CLUSTERING                              | 消息模型，支持一下两种：集群消费，广播消费                   |
| consumerFromWhere            | Consumer_FROM_LAST_OFFSET               | Consumer启动后，默认从什么位置开始消费                       |
| allocateMessageQueueStrategy | AllocateMessage QueueAveragelyRebalance | 算法实现策略                                                 |
| subscription                 | {}                                      | 订阅关系                                                     |
| messageListener              |                                         | 消息监听器                                                   |
| offsetStore                  |                                         | 消费进度存储                                                 |
| consumerThreadMin            | 10                                      | 消费线程池数量                                               |
| consumerThreadMax            | 20                                      | 消费线程池数量                                               |
| consumeConsurrentlMaxSpan    | 2000                                    | 单队列并行消费允许的最大跨度                                 |
| pullThresholdForQueue        | 1000                                    | 拉消息本地队列缓冲消息最大数                                 |
| Pullinterval                 | 0                                       | 拉消息间隔，由于是长轮询，所以为0，但是如果应用了流控，也可以设置大于0的值，单位毫秒 |
| consumeMessageBatchMaxSize   | 1                                       | 批量消费，一次消费多少条消息                                 |
| pullBatchSize                | 32                                      | 批量拉消息，一次最多拉多少条                                 |

## **4. PullConsumer配置**

| 参数名                                | 默认值       | 说明                                                         |
| :------------------------------------ | :----------- | :----------------------------------------------------------- |
| consumerGroup                         |              | Consumer组名，多个Consumer如果属于一个应用，订阅同样的消息，且消费逻辑一致，则应将它们归为同一组 |
| brokerSuspendMaxTimeMills             | 20000        | 长轮询，Consumer拉消息请求在Broker挂起最长时间，单位毫秒     |
| consumerPullTimeout                   | 10000        | 非长轮询，拉消息超时时间，单位毫秒                           |
| consumerTimeoutMillisWhenSuspend      | 30000        | 长轮询，Consumer拉消息请求Broker挂起超过指定时间，客户端认为超时，单位毫秒 |
| messageModel                          | BROADCASTING | 消息类型，支持一下两种：集群消费；广播模式                   |
| messageQueueListener                  |              | 监听队列变化                                                 |
| offsetStore                           |              | 消费进度存储                                                 |
| registerTopics                        |              | 注册的topic集合                                              |
| allocateMessageQueueStrategyRebalance |              | 算法实现策略                                                 |

1. Broker参数配置

| 参数名                            | 默认值                   | 说明                                                         |
| :-------------------------------- | :----------------------- | :----------------------------------------------------------- |
| listenPort                        | 10911                    | Broker对外服务的监听端口                                     |
| namesrvAddr                       | Null                     | NameServer地址                                               |
| brokerIP1                         | 本机IP                   | 本机ip地址，默认系统自动识别，但是某些多网卡机器会存在识别错误的情况，这种情况下可以人工配置 |
| brokerName                        |                          | 本机主机名                                                   |
| brokerClusterName                 | DefaultCluster           | Broker所属那个集群                                           |
| brokerId                          | 0                        | BrokerId,必须是大于等于0的整数，0表示Master, 大于0表示Slave, 一个Master可以挂多个Slave,Master和Slave通过BrokerName来配对 |
| storePathCommitLog                | $HOME/store/commitlog    | commitLog存储路径                                            |
| storePathConsumerQueue            | $HOME/store/consumequeue | 消费队列存储路径                                             |
| storePathIndex                    | $HOME/store/index        | 消息索引存储队列                                             |
| deleteWhen                        | 4                        | 删除时间点，默认凌晨4点                                      |
| fileReserverdTime                 | 48                       | 文件保留时间，默认48小时                                     |
| maxTransferBytesOnMessageInMemory | 262144                   | 单次pull消息（内存）传输的最大字节数                         |
| maxTransferCountOnMessageInMemory | 32                       | 单次pull消息（内存）传输的最大条数                           |
| maxTransferBytesOnMessageInDisk   | 65535                    | 单次Pull消息（磁盘）传输的最大字节数                         |
| maxTransferCountOnMessageInDisk   | 8                        | 单次pull消息（磁盘）传输的最大条数                           |
| messageIndexEnable                | TRUE                     | 是否开启消息索引功能                                         |
| messageIndexSafe                  | FALSE                    | 是否提供安全的消息索引机制，索引保证不丢                     |
| brokerRole                        | ASYNC_MASTER             | Broker的角色：ASYNC_MASTER异步复制Master; SYNC_MASTER同步双写MASTER; SLAVE |
| flushDiskType                     | ASYNC_FLUSH              | 刷盘方式： ASYNC_FLUSH异步刷盘；SYNC_FLUSH同步刷盘clientFileForciblyEnable |
