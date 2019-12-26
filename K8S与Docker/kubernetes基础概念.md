## Pod
[针对pod的理解](针对Pod的理解.md)
## 命名空间
```
命名空间相当于k8s中的多租户概念
但是命名空间默认并不提供网络隔离，比如namespace中的pod A可以访问namespace的pod B，除非k8s设置了命名空间的网络隔离
```
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
        httpGet:
          port: 8080
          path: /
```
