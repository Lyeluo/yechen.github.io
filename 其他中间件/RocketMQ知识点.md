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
