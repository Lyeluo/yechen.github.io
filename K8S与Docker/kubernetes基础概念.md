## Pod
[针对pod的理解](针对Pod的理解.md)
## 命名空间
```
命名空间相当于k8s中的多租户概念
但是命名空间默认并不提供网络隔离，比如namespace中的pod A可以访问namespace的pod B，除非k8s设置了命名空间的网络隔离
```
## ReplicationController & ReplicaSet
[ReplicationController &ReplicaSet的相关概念](ReplicationController&ReplicaSet.md)  
## DaemonSet
DaemonSet负责在kubernetes的每一个节点上运行一个pod，通常用作日志收集和资源控制器的部署，并维持每个节点始终运行一个pod，
同时可以通过配置节点选择器，来匹配在哪些节点上面运行pod    
1 . 创建
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: app
spec:
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      #模板：选取带有disk标签且值为ssd的节点部署pod
      nodeSelector:
        disk: ssd
      containers:
        - name: app
          image: app/1.0
          ports:
            - containerPort: 8080
```
2 . 向节点打标签
```bash
kubectl label node nodename disk=ssd
```
3 . 变更节点的标签
```bash
kubectl label node nodename disk=hdd --overwrite 
``` 
