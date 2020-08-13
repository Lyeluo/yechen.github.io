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
