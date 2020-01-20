## Statefulset
Statefulset与ReplicaSet/ReplicationController的区别：
+ ReplicaSet/ReplicationController就好比牧场中的牛，死掉一个然后补上一个，牧场主不会发觉有什么改变。
+ Statefulset就好比宠物，死掉一个，然后很难找到完全相似的宠物，但是Statefulset可以创建一个完全一样的宠物出来。
+ Statefulset创建的每一个pod有独立的数据卷，而且Statefulset创建的pod有固定的名称，是根据pod顺序定义的，即使挂掉重建后名称仍然不会变。
![Statefulset的pod名称固定](../images/1579145402(1).jpg) 

这里面宠物对应的就是kubernetes中的pod。
##### 在kubernetes集群内部通过域名访问pod
一个default命名空间中的Statefulset的一个pod，名为podA-0，service服务名为foo，那么他的域名为：`podA-0.foo.default.svc.cluster.local`  
##### 替换pod
Statefulset在替换pod的时候，会创建一个与旧pod完全一致的新pod，这个新的pod不一定与旧pod在同一个节点上。
但是仍然可以通过主机名进行访问。  

Statefulset在创建pod的时候，会根据顺序生成pod名称，如根据创建生成：podA-0、podA-1、podA-2.然后在删除时会从序号高的pod开始删除。  

Statefulset缩容会一个一个的删除pod，为了保证数据能有时间存储到存储应用。所以在集群节点中有不健康的pod时，是不允许执行缩容操作的。  
##### 卷声明模板
因为Statefulset中每一个pod需要单独持久化pod数据，而且需要与pod解耦，所以就用到持久卷。而我们又不可能手动为每一个pod单独创建持久卷声明，
所以就出现了持久卷声明模板。持久卷模板会在Statefulset创建创建pod之前创建其对应的持久卷声明，然后pod创建后将其绑定。  

在进行缩容的过程中，PVC与PV并不会自动删除，需要我们手动删除，删除PVC的时候会自动删除PV。目的就是为了防止误操作导致缩容，保留卷的话，
在重新扩容后，新的pod会保留与原pod完全一致的属性，如下图：  
![Statefulset缩容与扩容](../images/1579243692(1).jpg)

+ kubernetes必须保证具有相同标记和绑定持久卷声明的有状态pod实例不能同时运行
## 创建Statefulset
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: app
spec:
  selector:
    matchLabels:
      app: app
  serviceName: appservice
  replicas: 2
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
        - name: app
          image: app
          volumeMounts:
          # 指明绑定的持久卷声明模板名称与卷地址
            - mountPath: data
              name:   /var/data
  # 创建持久卷声明的模板            
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        resources:
          requests:
            storage: 1Mi
        accessModes:
          - ReadWriteOnce
```
Statefulset创建pod的方式与ReplicaSet或ReplicationController不同，他创建pod会依次创建，只有当一个pod创建成功并且运行正常后
才会创建下一个pod。  
生成的PVC的名称是：持久卷声明模板定义的名称+pod的名称  
## 通过Api服务器访问
需要首先开启代理服务，然后访问下面地址即可
#### 访问pod
`<apiServerHost>:<port>/api/v1/namespaces/default/pods/<pod名称>/proxy/<path>`
#### 访问service
`<apiServerHost>:<port>/api/v1/namespaces/default/services/<service名称>/proxy/<path>`
## Statefulset节点丢失处理方法
如果在Statefulset运行期间，下属的有一个pod所在的节点挂掉了，或者丢失了节点的信息。在集群其他机器查询时会发现pod的状态会变为Terminating，
但是kubernetes已经失去了对这个节点的控制，所以当他想要通知这个pod所在的节点删除pod进而重新部署pod时，会失败。那么这个pod就挂在了kubernetes上面，但是实际上上一个无效的pod。  

注意：这个pod里的容器不一定是挂掉的，这要取决于这个pod所在节点是挂掉了还是仅仅失去了与kubernetes的关联，总的来说kubernetes只是对节点失去了控制。  

#### 解决方法
需要删除掉pod然后让StatefulSet重新部署，此时使用普通的删除节点的方式`kubectl delete po kubia-0`，是无法生效的，因为在kubernetes看来这个pod已经删除了，
只是pod所在的节点没有通知API服务器说这个pod的容器已经终止，而这个节点已经脱离了kubernetes的控制了，所以这个操作需要由我们调用API服务器，强制删除pod。
执行命令`kubectl delete po kubia-0 --force --grace-period 0` 通知API服务器强制删除pod  

注意：除非确定节点永远起不来了，否则不要删除有状态的pod

## 问题
1. headless service与statefulSet有什么关系？  
