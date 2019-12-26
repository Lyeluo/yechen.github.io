## pod共享相同的IP地址和端口空间。  
这意味着在同一 pod中的容器运行的 多个进程需要注意不能绑定到相同的端口号， 否则会导致端口冲突，  
但这只涉及同一pod中的容器。 由于每个pod都有独立的端口空间， 对于不同 pod中的容器来说 则永远不会遇到端口冲突  
一个 pod中的所有容器也都具有相同的loopback 网络接口， 因此容器可以通过localhost 与同一 pod中的其他容器进行通信。  
## pod中的容器  
k8s中的思想是：每个容器只安装一个进程，然后多个或一个容器属于一个pod。然后这个pod下的容器可以通过volume的方式共享磁盘。  
也就是说，应该把整个pod看作虚拟机，然后每个容器相当于运行在虚拟机的进程。  
## 将多层应用分散到多个 pod 中   
虽然可以把多个容器放在同一个pod下，但是应该根据应用将容器分布到不同的pod中。原因如下：
+ 每个pod是部署再固定的node上的，将前端、后端应用部署在同一个pod里发挥不出集群的作用  
+ 当需要进行节点扩容的时候，如果前后端在一个pod里，扩容一个pod后就有两个前端、后端，这样多出的前端是没有意义的而且很有难度  
## 何时在pod使用多个容器  
+ 一般情况下建议单容器pod
+ 多容器需要同时扩缩容，是否必须一起运行，代表的是一个主体还是多个独立的组件  
## 只运行一次的Pod-Job
Job是一种特殊的Pod，只会执行一次，执行完毕之后就会进入已完成状态，之所以不会删除是为了查看日志  
1. 创建脚本
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  # 执行最大时间，超时则停止执行 并标记失败
  activeDeadlineSeconds: 30
  # 最多重试次数，默认为6
  backoffLimit: 3
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      # job的重启策略不能使用默认的Always
      restartPolicy: OnFailure
      containers:
        - name: main
          image: batch-job/1.0
```  
Job可以创建多个pod，通过配置使他们串行执行或者并行执行  

2. 串行执行多个,配置completions参数
```yaml
spec:
  # 执行最大时间，超时则停止执行 并标记失败
  activeDeadlineSeconds: 30
  # 最多重试次数，默认为6
  backoffLimit: 3
  completions: 5
  template:
    metadata:
      labels:
        app: batch-job
```
3. 并行执行多个，配置parallelism参数，表示最多可以几个pod并行执行  
```yaml
spec:
  # 执行最大时间，超时则停止执行 并标记失败
  activeDeadlineSeconds: 30
  # 最多重试次数，默认为6
  backoffLimit: 3
  completions: 5
  parallelism: 2
  template:
    metadata:
      labels:
        app: batch-job
```
4. 定时执行的job
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: batch-job-cron
spec:
  # cron表达式
  schedule: "0,15,30,45 * * * *"
  # pod必须在预定时间15s后执行，否则判定为执行失败
  startingDeadlineSeconds: 15
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: batch-job-cron
        spec:
          # job的重启策略不能使用默认的Always
          restartPolicy: OnFailure
          containers:
            - name: main
              image: batch-job/1.0
```
