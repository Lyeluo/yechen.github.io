## ReplicationController
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
```yaml
spec:
  selector:
    matchExpressions:
      - key: app
        operator: In
        values:
          - app
```
每个表达式都必须包含一个key、一 个operator(运算符），并且可能还有一个values的列表（取决于运算符），运算符如下：   
+ In : Label的值必须与其中一个指定的values匹配。  
+ Notln : Label的值与任何指定的values不匹配。 
+ Exists : pod必须包含一个指定名称的标签（值不重要）。使用此运算符时， 不应指定values字段。  
+ DoesNotExist : pod不得包含有指定名称的标签。values属性不得指定  

如果你指定了多个表达式，则所有这些表达式都必须为true才能使选择器与 pod匹配。如果同时指定matchLabels和matchExpressions, 则所有标签都必须匹配，并且所有表达式必须计算为true以使该pod与选择器匹配    

3 . 删除Rs
```bash
kubectl delete rs kubia
```  

4 . 注意：更改yaml的模板对现有pod不会产生影响，但是更改标签选择器会立即生效，如果当前标签没有符合更改后的标签选择器,rs或rc会立即创建pod，保持设置的数量  
