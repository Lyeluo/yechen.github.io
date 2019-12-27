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
所以若是有一节点挂掉了，然后恰好我们访问时输入的ip就是这个节点的，那么这个服务就完全不通了。  
但是，负责均衡器则不同，其的位置在node的前面，即便节点挂掉了，也会将请求转发到其他节点上。  
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
