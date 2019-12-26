## ReplicationController & Deployment
### 存活探针
Kubemetes有以下三种探测容器的机制： 
+ HTTPGET探针对容器的IP地址（你指定的端口和路径）执行HTTPGET请求，如果探测器收到响应，并且响应状态码不代表错误（换句话说，如果HTTP 响应状态码是2xx或3xx), 则认为探测成功。  
如果服务器返回错误响应状态 码或者根本没有响应，那么探测就被认为是失败的，容器将被重新启动。  
+ TCP套接字探针尝试与容器指定端口建立TCP连接。如果连接成功建立，则 探测成功。否则，容器重新启动。   
+ Exec探针在容器内执行任意命令，并检查命令的退出状态码。如果状态码 是o, 则探测成功。所有其他状态码都被认为失败。   
#### 基于HTTP的存活探针 
创建(只截取容器配置的部分)
```yaml
spec:
  containers:
    - name: IMAGE_NAME
      image: WAREHOUSE/NAMESPACE/IMAGE_NAME:TAG
      # 一个基于HTTP GET的存活探针
      livenessProbe:
        # 第一次检测在容器启动15秒后
        initialDelaySeconds: 15
        httpGet:
          port: 8080
          path: /
```
## ReplicationController
1. 创建ReplicationController的yaml
```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: app
spec:
# 这里的selector可以删除，这样的话会默认从模板（template）中获取标签
  selector:
    app: app
  replicas: 2
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
        - name: app
          image: app/1.0
          ports:
            - containerPort: 8080
```
2 . ReplicationController（Rc）会根据标签选择器管理符合其标签的所有pod，并维持在replicas设置的数量上。  
 当有一个pod发生故障然后又需要保留pod以查询日志信息的时候，可以更改pod的标签来移出ReplicationController的管理范围，
这样Rc会重新创建一个pod，故障pod也不会删除，仍然可以根据日志分析故障原因    
3 . 注意：修改yaml文件的模板或者标签选择器时，要删除之前创建的pod，不然pod会失去Rc的管理，白白占用内存空间，类似于java中的内存泄漏  
4 . 直接编辑Rc的yaml命令,命令执行后会自动生效，可以用来升级pod，但是后面有更好的方法
```
kubectl edit rc myapp  
```  
5 . 有的时候需要删除Rc但是不能删除Rc下面管理的pod，比如需要将Rc升级到ReplicaSet（Rs）,可以执行以下命令
```bash
kubectl delete re kubia --cascade=false 
``` 
## ReplicationController 与 ReplicaSet 的对比
目前ReplicationController已经被ReplicaSet完全取代了，而我们也不会直接去创建ReplicaSet，是使用Deployment去管理ReplicaSet，在后面会讲到  
+ ReplicaSet对标签的匹配规则更加多样化  
+ ReplicaSet可以将标签选择器设置为一个数组，只要是这个数组里的标签都会被匹配  
1 . 创建ReplicaSet
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: app
spec:
  selector:
    matchLabels:
      app: app
  replicas: 2
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
        - name: app
          image: app/1.0
          ports:
            - containerPort: 8080
```
2 . 更加强大的标签选择器：matchExpressions   
![matchExpressions标签匹配的规则](../images/1577351639(1).jpg)  
3 . 删除rs及下属pod
```bash
kubectl delete re kubia
```
