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
### deployment的yaml文件及一些命令

+ 创建命令`kubectl create -f deply.yaml --record`  
--record 命令会记录历史版本号
+ 修改deployment的命令：`kubectl patch deployment deploymentName -p`  
kubectl patch命令会更改Deployment的自由属性，并不会导致pod的更新，因为pod的模板没有被修改。更改Deployment的其他属性也不会
导致滚动升级，例如：副本数或者部署策略  
+ 修改Deployment的镜像模板：`kubectl set image deployment deploymentName `
### 修改 Deployment 或其他资源的不同方式
|方法  | 作用| 例子| 
|:------- |:-------|:-------|
| kubectl edit | 使用默认编辑器打开资源配置。修改保存并退出编辑器，资源对象会被更新 | kubectl edit deployment kubia |
| kubectl patch | 修改单个资源属性 | kubectl patch deployment deploymentName -p json格式的数据 | 
| kubectl apply | 通过一个完整的yaml或json文件来修改资源，如果文件中定义的资源不存在，会创建一个。文件中对资源的描述必须全面，不能像patch那样 | kubectl apply -f kubia-deploy.yaml | 
| kubectl replace | 将原有对象替换为yaml/json中定义的新对象。如果原有对象不存在，会报错 | kubectl replace -f kubia-deploy.yaml | 
| kubectl set image | 修改pod、rs、rc、deployment、DemonSet、job中的镜像 | kubectl set image deployment kubia nodejs=luksa/kubia:v2 |   
以上这些方式修改完Deployment资源后，会自动触发滚动升级
