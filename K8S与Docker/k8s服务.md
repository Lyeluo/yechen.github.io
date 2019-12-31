## Service
1. 创建方式
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app
spec:
  # 可以通过配置sessionAffinity将监听到的来自同一ClientIp的请求转发到同一个pod上
  sessionAffinity: ClientIp
  ports:
    # 监听容器的80端口
    - port: 80
    # 将监听到的80端口的请求转发到内部服务的8080端口上
      targetPort: 8080
  selector:
    app: app
```
2. 如果需要配置多个端口，增加ports下的port即可，但是需要注意 所有的pod必须使用同一个标签选择器，如果要使用不同的标签选择器
需要创建多个service服务才可以  
 ```yaml
spec:
  ports:
    - name: service
      port: 18103
      targetPort: 18103
    - name: debug
      port: 18203
      targetPort: 18203
      nodePort: 32202
  selector:
    app: IMAGE_NAME
```
3. 可以通过在pod中对端口命名的方式，来与service进行匹配，这样就相当于降低了端口的耦合
```yaml
# service
spec:
  ports:
    - name: service
      port: 18103
      targetPort: service
---   
# pod
spec : 
  containers: 
    - name: kubia
  ports : 
    - name : service 
      containerPort 8080
```
4. 对于同一个命名空间下的服务，可以直接通过服务名称访问；对于不同命名空间的服务，需要添加命名空间.集群域后缀，如下：  
```bash
backend-database.default.svc.cluster.local
```
+ backend-database:服务名称
+ default：命名空间名称
+ svc.cluster.local 集群域名称
## 暴露服务给外部客户端
+ 将服务的类型设置成NodePort-每个集群节点都会在节点上打 开 一个端口， 对于NodePort服务， 每个集群节点在节点本身（因此得名叫
NodePort)上打开一个端口，并将在该端口上接收到的流量重定向到基础服务。该服务仅在内部集群 IP 和端口上才可访间， 但也可通过所有节点上的专用端
口访问。
+ 将服务的类型设置成LoadBalance, NodePort类型的一 种扩展一—这使得服务可以通过一个专用的负载均衡器来访问， 这是由Kubernetes中正在运行
的云基础设施提供的。 负载均衡器将流量重定向到跨所有节点的节点端口。客户端通过负载均衡器的 IP 连接到服务。
+ 创建一 个Ingress资源， 这是一 个完全不同的机制， 通过一 个IP地址公开多个服务——它运行在 HTTP 层（网络协议第7 层）上， 因此可以提供比工作
在第4层的服务更多的功能。
1. NodePort
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app
spec:
  # 设置服务类型
  type: NodePort
  ports:
    - port: 80
      targetPort: 8080
      # 集群释放端口。集群中的所有节点都会释放这个端口，并将传入的链接转给监听的80端口
      # nodePort可以省略，如果省略的话会由k8s为我们分配端口
      nodePort: 32101
  selector:
    app: app
```
原理图如下：  
![nodePort类型原理图](../images/1577430534(1).jpg)  
2. LoadBalance  
如果是使用云服务器商提供的kubernetes，会提供一个负载平衡器，负载平衡器有自己的固定ip。在普通的NodePort类型的service上，访问任一节点上的端口
会由node节点将请求转发给service，然后service再根据匹配规则随机将请求转发到任一节点的pod上。    
所以若是没有使用负载均衡器，有一节点挂掉了，然后恰好我们访问时输入的ip就是这个节点的，那么这个服务就完全不通了。  
但是，有负责均衡器则不同，其的位置在node的前面，即便节点挂掉了，也会将请求转发到其他节点上。  
而且相对于nodeport，这种方式不需要关闭k8s的防火墙  
原理图如下：  
![LoadBalance类型原理图](../images/1577430834(1).jpg)  
3. 外部链接的特性
+ 可以通过配置spec来指定，接收链接的pod所在的节点必须是访问链接时的ip对应的节点，如果该节点不存在pod，则挂起链接
```yaml
spec：
  externalTrafficPolicy: Local
```
+ 无法获取到访问服务的客户端ip，因为在接收请求时，服务内部进行了节点间的转发，请求的来源ip已经发生了变化
所以获取不到客户端ip
3. Ingress  
若是仅使用LoadBalancer，每个LoadBalancer服务都需要一个公网ip,而Ingress只需要一个公网ip就可以根据请求的主机名和
路径决定请求转发到LoadBalancer的服务上，感觉上有点像是nginx，如下图：  
![Ingress结构图](../images/1577757040(1).jpg)  
创建Ingress
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: app
spec:
  rules:
    # 接收域名为yechen.example.com的请求
    - host: yechen.example.com
      http:
        paths:
          # 匹配所有路径
          - path: /
            backend:
              # 请求转发到名为app-nodeport的服务上
              serviceName: app-nodeport
              servicePort: 8080
```
Ingress原理，Ingress接收到请求后不会直接把请求转发给服务，而是根据匹配的服务去找到服务下的podIp，然后Ingress
根据这个Ip去将请求转发给这个pod，原理图如下：
![Ingress原理图](../images/1577758014(1).jpg)  
Ingress也支持HTTPS，具体方法可以参考《kubernetes 实战》149页内容  
## 就绪探针
有时pod启动可能需要很多的准备时间，在这个时间不希望服务将请求转发进来，让第一个用户的第一个请求时间太长，所以需要一个工具来
判断pod是否已经启动完毕。  
与存活探针一样，就绪探针有三种方式：
+ Exec 探针，执行进程的地方。容器的状态由进程的退出状态代码确定  
+ HTTP GET 探针，向容器发送 HTTP GET 请求，通过响应的 HTTP 状态代码判断容器是否准备好  
+ TCP socket 探针，它打开一个TCP连接到容器的指定端口。如果连接己建立，则认为容器己准备就绪  

如果某个pod报告它尚未准备就绪，则会从该服务中删除该 pod 。如果再次准备就绪，则重新添加该pod进来  
如下就是一个httpGet的探针添加方法，添加在ReplicationController中
```yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          readinessProbe:
            httpGet:
              port: 8080
              path: /healthz
          ports:
            - containerPort: 8080
```
+ 务必定义就绪探针
## Headless
是一种特殊的Service，通过DNS轮询机制来实现pod的负载均衡，而不是服务代理。由服务返回给用户真正的podIp，然后用户直接调用这个podIp，
创建方式：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app
spec:
# 通过设置clusterIP为None来将Service服务变为Headless服务
  clusterIP: None
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: app
```
+ 备注：这里我理解还可能不是很明确，也不知道应用场景，所以暂时不进行仔细研究了

看到这里是对前面的service也有了一些理解，service主要是来为我们进行服务代理的，我们可以通过访问集群ip然后访问service，然后由service去
动态根据标签选择器查找对应的podIp，然后转发用户的请求。如果是在同一个集群内也可以通过service的集群ip（10开头的那个）直接调用service服务，
也可以直接通过podIp去调用pod中的服务，但是必须在同一个集群内部才可以。
## 排除服务故障的方法
+ 首先， 确保从集群内连接到服务的集群IP,而不是从外部。
+ 不要通过ping服务IP 来判断服务是否可以访问（请记住， 服务的集群IP 是虚拟IP, 是无法ping通的）。
+ 如果已经定义了就绪探针， 请确保它返回成功；否则该pod不会成为服务的一部分 。
+ 要确认某个容器是服务的一部分， 请使用kubectl get endpoints来检查相应的端点对象。
+ 如果尝试通过FQDN或其中一部分来访问服务（例如， myservice.mynamespace.svc.cluster.local或 myservice.mynamespace), 但
并不起作用， 请查看是否可以使用其集群IP而不是FQDN来访问服务 。
+ 检查是否连接到服务公开的端口，而不是目标端口 。
+ 尝试直接连接到podIP以确认pod正在接收正确端口上的连接。
+ 如果甚至无法通过pod的IP访问应用， 请确保应用不是仅绑定到本地主机。
