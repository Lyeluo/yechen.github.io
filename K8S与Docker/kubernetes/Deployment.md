[[toc]]
## Deployment
在我们发布容器中的服务时，总共有一下几种方式：  
+ 将旧的pod停掉，创建新的pod并发布  
+ 创建新的pod，然后将旧的pod停掉
+ 滚动式升级。创建一个新的pod，删除一个旧的pod，直到所有的旧pod都被替换  
其中最完美的升级方式就是滚动式升级，但是操作命令过于复杂，而kubernetes提供的rolling-update方式也存在着会修改原有pod标签、
kubectl所在服务器故障导致升级中断等风险。而Deployment就是为了完美解决这个问题诞生的。  
Deployment创建后，会自动创建一个ReplicaSet，然后由其来创建pod。  

### Deployment的升级策略
+ 滚动更新（RollingUpdate）：默认策略，如果我们的服务支持多个版本同时运行，可以选择这个策略。
+ Recreate：会一次性删除所有旧版本的pod，然后创建新的pod。如果我们的服务不支持多个版本运行，并且允许服务出现短暂的停用，
可以选择这个策略。  
Deployment升级过程：自动创建一个新的ReplicaSet然后慢慢从0开始扩容，旧的ReplicaSet慢慢缩容至0,然后完成滚动升级。升级完成后，
旧版本的ReplicaSet并不会被自动删除，而是会保留下来，方便回滚时使用。默认会保留升级过程中的两个旧版本ReplicaSet  
![Deployment滚动升级过程](../images/1579076023(1).jpg)
### deployment的yaml文件及一些命令

+ 创建命令`kubectl create -f deply.yaml --record`  
--record 命令会记录历史版本号
+ 修改deployment的命令：`kubectl patch deployment deploymentName -p`  
kubectl patch命令会更改Deployment的自由属性，并不会导致pod的更新，因为pod的模板没有被修改。更改Deployment的其他属性也不会
导致滚动升级，例如：副本数或者部署策略  
+ 修改Deployment的镜像模板：`kubectl set image deployment deploymentName `
+ 查看Deployment的升级过程：`kubectl rollout status`  
+ 查看Deployment升级过程中的历史版本：`kubectl rollout history deployment kubia` 
+ 回滚Deployment：`kubectl rollout undo deployment kubia`
+ 回滚Deployment到指定版本：`kubectl rollout undo deployment kubia --to-revision=1`
### 修改 Deployment 或其他资源的不同方式
|方法  | 作用| 例子| 
|:------- |:-------|:-------|
| kubectl edit | 使用默认编辑器打开资源配置。修改保存并退出编辑器，资源对象会被更新 | kubectl edit deployment kubia |
| kubectl patch | 修改单个资源属性 | kubectl patch deployment deploymentName -p json格式的数据 | 
| kubectl apply | 通过一个完整的yaml或json文件来修改资源，如果文件中定义的资源不存在，会创建一个。文件中对资源的描述必须全面，不能像patch那样 | kubectl apply -f kubia-deploy.yaml | 
| kubectl replace | 将原有对象替换为yaml/json中定义的新对象。如果原有对象不存在，会报错 | kubectl replace -f kubia-deploy.yaml | 
| kubectl set image | 修改pod、rs、rc、deployment、DemonSet、job中的镜像 | kubectl set image deployment kubia nodejs=luksa/kubia:v2 |   

以上这些方式修改完Deployment资源后，会自动触发滚动升级

注意：如果Deployment的pod模板引用了一个configmap/secret，那么更改configmap资源不会触发升级。需要创建一个新的configmap
然后需改pod模板引用新的configmap。
### 滚动升级的相关控制
1. 在升级过程中可以控制一次替换多少个pod
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  selector:
    matchLabels:
      name: app
  strategy:
    rollingUpdate:
    # 决定了在升级过程中最多允许超出期待副本数的数量，默认为25%
    # 如果期待副本数为4，那么运行时不会超过5个pod实例
    # 如果设置的不是百分数的化，则代表的允许的最大超过数量，下面这个就是指最大超过一个
      maxSurge: 1
    # 决定了在升级过程中，最多允许多少个pod处于不可用状态，默认为25%
    # 如果期待数量为4，那么可用的pod数量最低为3
    # 如果设置的不是百分数的化，则代表的允许的最大不可用数量，下面这个就是指最大不可用数为0
      maxUnavailable: 0
```
2. 暂停滚动升级  
将一个Deployment创建几秒后，暂停该Deployment，这样的话会创建一个新的pod，同时旧的pod依然在运行。
这就是所谓的金丝雀发布，可以用来验证新版本的运行使用情况。验证完毕后可以继续升级或回滚旧版本。  

目前还无法实现在一个确定的位置暂时滚动升级以达到金丝雀发布，所以上述方法还不健全。
可以操作的是可以创建两个不同的deployment，然后通过控制其pod数量来实现金丝雀发布
```yaml
kubectl rollout pause deployment kubia
```
3. 恢复滚动升级  
```yaml
kubectl rollout resume deployment kubia
```
因为修改Deployment时会自动触发滚动升级，如果不想立即升级，可以通过不停的使用暂停滚动升级，直到对deployment的修改完毕后，再恢复滚动升级。  
### 阻止出错版本的滚动升级
可以通过Deployment的spec.minReadySeconds和就绪探针实现，升级过程中发现新版本故障，自动停止升级。
  
minReadySeconds指的是，新创建的pod至少要成功运行多久之后 ，才能将其视为可用，在这个期间内，deployment不会继续滚动升级，除非这个pod已经被视为可用。  

在升级过程中，pod的就绪探针返回成功后，kubernetes才会视为pod可用，而在deployment升级过程中只有在minReadySeconds时间内，
pod的就绪探针没有失败，才会判断为这个新版本pod发布没有问题，然后继续后面的滚动升级动作，否则会阻止滚动升级。

可以通过设置Deployment的spec.progressDeadlineSeconds值来定义升级的时间限制，如果在设置时间内没有完成升级，则会停止升级动作。
## Deployment的创建过程
准备包含Deployment清单的YAML文件， 通过kubectl提交到Kubernetes。kubectl通过HTTP POST请求发送清单到Kubernetes API服务器。 API服务器检
查Deployment定义，存储到etcd, 返回响应给kubect。
![Deployment的创建过程](../images/1594087745(1).jpg)
