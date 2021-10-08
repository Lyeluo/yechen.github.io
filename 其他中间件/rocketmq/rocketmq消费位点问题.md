## 消费进度如何管理的？

在上文中我们已经提过消费进度的管理方式：

> RocketMQ是以consumer group+queue为单位是管理消费进度的，以一个consumer offset标记这个这个消费组在这条queue上的消费进度。
> 如果某已存在的消费组出现了新消费实例的时候，依靠这个组的消费进度，就可以判断第一次是从哪里开始拉取的。



总结起来话，有以下关键点

1.消费进度存储在broker端（CLUSTER模式），以消费者组+queue的单位存储。类似：

```text
{
	"offsetTable":{
		"TopicTest@pullConsumerGroupTest":{0:1578,1:1578,2:1578,3:1578
		}
	}
}
```

这里讲的是对于TopicTest这个topic，pullConsumerGroupTest这个消费者组的各个队列的offset位点，其中队列0到1578 ，队列1到1578....。详情大家可以去broker的存储目录下找config/consumerOffset.json看看。

2.一切只要能找到消费位点的记录的，都遵循broker返回的位点位置，作为第一次拉取消息的请求参数之一。

3.找不到这个位点的话，那么就是新的订阅关系/新的consumer group启动，那么就让客户端自己决定（ConsumeFromWhere策略）。即CONSUME_FROM_LAST_OFFSET，CONSUME_FROM_FIRST_OFFSET，CONSUME_FROM_TIMESTAMP这三个策略，默认情况下是CONSUME_FROM_LAST_OFFSET。



## 老消费者组继续消费的管理方式

基于以上结论，一个老的消费者组启动，如果监听的topic消息消费到了100，但是最大的消息位点现在已经到了200，那么后面这一百条消息是还会继续消费的，**无论你的ConsumeFromWhere策略配置了什么**

这很好理解，就像你一台服务挂了半小时，这时候堆积了100条消息，没有消费，不可能你因为重启就跳过不消费。

所以，如果你的CONSUME_FROM_LAST不生效，请先问问自己是否属于以下两个情况：

1. 这个消费者组本来就监听这个Topic，你修改ConsumeFromWhere策略发布。对不起，这时候这个策略对于这个topic是不生效的
2. 这个消费者组本来就监听**过**这个Topic，但是由于后面服务发版的历史中，已经不监听了。但突然有一天，你发现又需要重新监听了，这时候ConsumeFromWhere**也是不生效的。原因就是这个消费进度一直都被broker记住了。**

针对以上两个场景，如果希望跳过堆积的消息**，**[Jaskey Lam：RocketMQ原理（4）——消息ACK机制及消费进度管理](https://zhuanlan.zhihu.com/p/25265380) 中有提过一些解决方案，这里不赘述。



## 新消费者组初始消费的管理方式

首先，需要强调一下的是：这里的说的新消费者不仅仅说一个之前完全不存在的新消费者组才属于新消费者组。事实上，按照上文讲的文件存储的结构：只要 consumer group+topic+queue 这三个维度产生了新的关系，都会认为是新消费者组（严格说，是针对新订阅的topic/queue而言，是新消费者组）。



故：以下都会走后面说的新消费者组管理逻辑

1.全新的消费者组启动并开始监听

2.一个老的消费者组，新监听一个已经存在的topic

3.一个老的消费者组，监听的topic没有发生变化，但是topic的读queue数量扩容了。例如原来是3条，后面动态配置为6条，那么针对后面多出来的3条，就认为是新消费者组

4.一个老的消费者组，监听的topic没有发生变化，但是broker扩容了——对应的topic在新的broker也建立了（从集群的角度俯视，topic的queue数量扩容了），那么针对多出来的这些queue，也是走新的消费者组逻辑



注：由于一个broker的特殊处理（可以认为是bug），某些情况下不会完全走新消费者组逻辑，后面会提到。



而RocketMQ整个过程中，在启动第一次初始化消费位点的时候，就需要判断是否走新消费者组逻辑还是旧消费者组逻辑。

具体如何判断的呢？在负载均衡分配完queue后，客户端针对每一个自己分配到的queue会去调用broker一个queryConsumerOffset接口，这个接口会判断这个消费者组是否有关于这个topic的这个queue存在消费进度的记录（即上文提到的consumerOffset.json），若有，则返回存储的消费offset，若无，则返回一个异常码：*QUERY_NOT_FOUND。*

*客户端拿到结果之后，如果发现正常返回offset（老消费者组），那么就按照这个值来消费。如果是发现是QUERY_NOT_FOUND这个返回码，就会让客户端自己决定。这时候就会走到上文我们说的*ConsumeFromWhere策略的逻辑了，以下是CONSUME_FROM_LAST_OFFSET策略核心源码，我增加了中文注释，其他策略实际大同小异这里不具体展开。

注：这里的lastOffset就是我们上文queryConsumerOffset broker返回的结果，如果返回了*QUERY_NOT_FOUND（被认为新消费者组），这里被赋值成了-1。*

```java
        switch (consumeFromWhere) {
            case CONSUME_FROM_LAST_OFFSET: {
                long lastOffset = offsetStore.readOffset(mq, ReadOffsetType.READ_FROM_STORE);
                if (lastOffset >= 0) {
                    result = lastOffset;
                }
                // First start,no offset
                else if (-1 == lastOffset) {//新消费者组
                    if (mq.getTopic().startsWith(MixAll.RETRY_GROUP_TOPIC_PREFIX)) {//重试队列都从队头消费
                        result = 0L;
                    } else {//拿当前队列的最大offset消费（CONSUME_FROM_LAST_OFFSET的语义）
                        try {
                            result = this.mQClientFactory.getMQAdminImpl().maxOffset(mq);
                        } catch (MQClientException e) {
                            result = -1;
                        }
                    }
                } else { //其他异常场景会是-2来到这里的else
                    result = -1;
                }
                break;
            }
            case CONSUME_FROM_FIRST_OFFSET: {
                ....
            }
            case CONSUME_FROM_TIMESTAMP: {
                ...
            }

            default:
                break;
        }
```







## 的确是全新的消费者组，为什么CONSUME_FROM_LAST_OFFSET还是不生效



讲道理，起始消费位点的管理的逻辑并不复杂，总结起来就是一句话：**broker有就按照broker的来，没有就按照客户端策略来。**上面讲的这么多其实就是这句话的展开。



但是，细心的人可能会发现，如果完全按照这种逻辑来，实际上可能会有问题的。其实主要问题就是上面的第三种情况：

> 3.一个老的消费者组，监听的topic没有发生变化，但是topic的读数量扩容了。例如原来是3条，后面动态配置为6条，那么针对后面多出来的3条，就认为是新消费者组

注：实际上，第四种情况本质也是一样的。



大家想想，一旦我实时扩容，这三条队列很可能很快就被生产者发送消息进去了；假设说我们扩容了一条队列，发了10条信息进这个队列。那么从扩容到生产到消费，会有以下的过程

1. 用户进行了一条队列的扩容 queueX
2. 生产者P发送了10条消息
3. 消费者触发负载均衡重新分配队列（因为队列数发生了变化，也需要rebalance，这和消费者数发生变化做的事是一样的）
4. 某个消费者C实例实时的分配到这个队列queueX
5. 判断起始消费位点，判断出一个消费位点O
6. 消费者C从O开始消费

**这时候问题就出在第五步！**按照我们上文所说的，由于对于队列queueX，实际上broker是没记录过消费进度的，按照上面这样的逻辑，很可能客户端针对这个queueX就会进入新消费组的逻辑，如果我们配置的策略是CONSUME_FROM_LAST_OFFSET，那么问题就来了，现在队列的LAST是10，所以消费的起始位点是10！也就是说对于一个实时在线的系统，**有10条消息居然被实时跳过了！对于消费者来说就好像消息丢失了一样！**



为了解决这个问题rocketmq在刚刚queryConsumerOffset这个broker接口里，增加了部分特殊判断：如果**认为**这个是新queue，就直接返回0，那么由于客户端发现broker有值，那么就尊重这个值，所以这时候客户端就能直接从0这个位置消费了，就不会丢失掉扩容时候的这些消息了。

如果你还是不能理解，想像上面说的第四种情况的扩容场景：

> 4.一个老的消费者组，监听的topic没有发生变化，但是broker扩容了——对应的topic在新的broker也建立了（从集群的角度俯视，topic的queue数量扩容了），那么针对多出来的这些queue，也是走新的消费者组逻辑

假设我们扩容一个新的broker到已有集群中，对于客户端消费者看来实际上就是新建了一个topic的队列。如果原来是：

> broker-0-topicA-0
> broker-0-topicA-1

而扩容后是

> broker-0-topicA-0
> broker-0-topicA-1
> broker-1-topicA-0
> broker-1-topicA-1

针对后面扩容的两个queue，你肯定**不希望丢失扩容时候发生进来的消息的**，所以做了这样的特殊处理。



但是正是这个逻辑的增加，**误杀**了一些场景。因为queryConsumerOffset接口里判断是否新queue的逻辑并不是很完善，这也是为什么我管它叫bug的原因。

以下是我增加了注释后的源码：

```text
long offset =
    this.brokerController.getConsumerOffsetManager().queryOffset(
        requestHeader.getConsumerGroup(), requestHeader.getTopic(), requestHeader.getQueueId());

if (offset >= 0) { //broker存储1进度，直接返回进度
    responseHeader.setOffset(offset);
    response.setCode(ResponseCode.SUCCESS);
    response.setRemark(null);
} else {
    long minOffset =
        this.brokerController.getMessageStore().getMinOffsetInQueue(requestHeader.getTopic(),
            requestHeader.getQueueId()); //计算一下当前这个queue的最小offset，如果是新的队列这个min offset肯定是0
    if (minOffset <= 0 //最小offset是0
        && !this.brokerController.getMessageStore().checkInDiskByConsumeOffset( //消息还在pagecache
        requestHeader.getTopic(), requestHeader.getQueueId(), 0)) {
        responseHeader.setOffset(0L);//为了避免扩容的时候消息被跳过，直接告诉客户端从0开始消费
        response.setCode(ResponseCode.SUCCESS);
        response.setRemark(null);
    } else { //认为是新的消费者组，返回QUERY_NOT_FOUND
        response.setCode(ResponseCode.QUERY_NOT_FOUND);
        response.setRemark("Not found, V3_0_6_SNAPSHOT maybe this group consumer boot first");
    }
}
```



问题就出现以下这一段if语句的判断，实际上误杀了很多非新queue的场景

```text
if (minOffset <= 0 //最小offset是0         && !this.brokerController.getMessageStore().checkInDiskByConsumeOffset( //消息还在pagecache     
```

先说后者，消息什么情况下会不在pageCache?这很大程度下取决于共享内存大小，所以如果实时消息量不大的情况下，可能好几天都还在pageCache，那么这个条件就是true。



再说前者，minOffset在https://zhuanlan.zhihu.com/p/25092361 一问中曾经解释过

> 由于消息存储一段时间后，消费会被物理地从磁盘删除，message queue的min offset也就对应增长。这意味着比min offset要小的那些消息已经不在broker上了，无法被消费。

也就是说，如果那条消息所在的消息文件没有被删除，这个minOffset会一直都是0。清理条件有两个可能的场景：1.周期超过72小时（默认值） 2.磁盘达到85%水位线（默认值）。实际上这两个磁盘清理条件对于大多数业务集群来说，都需要挺长的时间才会达到。

注：消息的清理是以文件为单位的，文件不够老的话，即使里面有一个一年前的消息都不会被清楚。



所以总结来说就是：对于很多集群，一个topic不呆个几天，很可能都被broker**误认为是扩容的topic。**这就是为什么很多人在测试环境测试总是发现CONSUME_FROM_LAST_OFFSET不生效，事实上CONSUME_FROM_TIMESTAMP也不生效，而最后感觉都是CONSUME_FROM_FIRST_OFFSET的策略，实际上并不是CONSUME_FROM_FIRST_OFFSET生效了，而是broker强行建议消费者从头开始消费了。



上面这个bug条件可能还是有点绕，而且**具备非常大的不确定性！的确比较坑。**

以下总结几个常见的CONSUME_FROM_LAST_OFFSET不生效bug场景：

1.刚新建不久的一个topic，里面有一些消息曾经发送过，起一个新的consumer group去消费，CONSUME_FROM_LAST_OFFSET可能不生效

2.某些测试环境，或某些累计消息量很小的灰度集群，新起的consumer group 去监听任意一个有消息的topic，CONSUME_FROM_LAST_OFFSET可能不生效。

3.新建一个集群，topic从老集群做了迁移，数据量即使很大，也会认为和#1场景一样。CONSUME_FROM_LAST_OFFSET可能不生效。



虽然两个条件的不确定性很大，但是对于第一个条件是否minOffset <= 0 ，我们是可以通过控制台/命令行去确认的，如下图是我一套测试环境的topic，都一个月了，minOffset其实还是0，证明消息量并不够，一直没被清理，那么针对这个topic，**很可能**我起一个新消费者也是要消费历史消息的。之所以说很可能，是因为还得看这个消息还在不在broker的page cache，这就很“**随缘“**了。



![img](https://pic3.zhimg.com/80/v2-1a7dad36876ed0c388aaa6ed4c2dd8ae_720w.jpg)





## 解决建议

那针对这些场景我们的确需要跳过，那怎么办？https://zhuanlan.zhihu.com/p/26119361 一文中给过一些建议，简单说就是

1. 代码中进行时间判断做跳过
2. 消费者组启动消费前前先重置一下消费进度，建议这种情况下手动创建消费者组，并把consumeEnable关闭让他不能消费，再调整进度，再重新开启consumeEnable

## 结语：

做个总结：

\1. 对于已经存在的消费者组+topic+queue的订阅关系，无论如何都是遵循历史进度进行消费

\2. 对于新的消费者组+topic+queue关系，在**正常情况下，遵循客户端配置的策略**

**3. 对于特殊的场景被broker认为queue是新queue的情况下，一律从头开始消费（令可杀错不放过）**



注：广播模式由于offset的存储在客户端，他没有能力判断是否是新queue，反而没有上面特殊场景的这个问题
