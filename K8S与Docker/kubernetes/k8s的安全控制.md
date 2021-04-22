## 配置容器级别的安全控制
### 使用宿主机的网络模式
可以通过设置pod的spec的hostNetwork参数为true开启容器的“host”network模式
```yaml
    spec:
      hostNetwork: true
      containers:
        - name: name
          image: Enter containers image
```
### 绑定宿主机的端口
这种方式不需要创建service来做port映射，相当于docker中的-p映射端口的操作
```yaml
    spec:
      containers:
        - name: name
          image: Enter containers image
          ports:
            # 容器内部的端口
            - containerPort: 8080
              # 映射在宿主机上的端口
              hostPort: 9000
              protocol: TCP
```
### 使用宿主机的PID和IPC命名空间
通过开启pod的spec.hostPID使用宿主机的pid，同样通过开始hostIPC使用宿主机的ipc
```yaml
    spec:
      hostPID: true
      hostIPC: true
      containers:
        - name: name
          image: Enter containers image
```
将hostPID设置为true，pod内就可以看到宿主机上的所有进程pid，同时自己的进程也会有宿主机管理。
将hostIPC设置为true，pod中的进程就可以与宿主机上的其他所有进程进行通信。  
## 配置pod的安全上下文
针对于container级别的控制
### 指定运行容器的用户
```yaml
    spec:
      containers:
        - name: name
          image: Enter containers image
          securityContext:
          # 405为容器中用户的id，这里仅可以通过id指定运行容器的用户
            runAsUser: 405
```
### 阻止容器以root用户运行
有的应用在容器中设置了运行用户，然后可能会有黑客上传一个以root用户运行的镜像到我们的镜像仓库。然后在容器中利用root用户
的权限，这样是很危险的，所以我们可以禁用容器中的root用户，让他不能以root用户启动容器
```yaml
    spec:
      containers:
        - name: name
          image: Enter containers image
          securityContext:
            runAsNonRoot: true
```
### 使用特权模式启动容器
使容器具有宿主机上的所有操作权限,这样容器中就可以使用宿主机上的设备了
```yaml
    spec:
      containers:
        - name: name
          image: Enter containers image
          securityContext:
            privileged: true
```
### 为容器添加linux内核的功能
使用特权模式启动的容器被赋予了过大的权限，我们可以根据需求给予容器所需的linux内核的能力。
```yaml
    spec:
      containers:
        - name: name
          image: Enter containers image
          securityContext:
            # 通过capabilities开启或者禁用linux的内核功能
            capabilities:
              # 授予容器能力
              add:
                - SYS_TIME
              # 禁用容器能力
              drop:
                - CHOWN
```
注意：在linux中内核功能通常以CAP_开头，这里需要省略掉
### 阻止容器对根目录的写入
```yaml
    spec:
      containers:
        - name: test-container
          image: test-container
          imagePullPolicy: IfNotPresent
          securityContext:
            # 这个容器的根目录不允许写入操作
            readOnlyRootFilesystem: true
          volumeMounts:
            # 但是允许向volume目录写入，这个目录是一个挂载卷
            - mountPath: /volume
              name: test-volume
              readOnly: false
      volumes:
        - name: test-volume
          emptyDir: {}
```
问题：如果不采用挂载的方式，可否将一个目录释放出来允许写入呢？
## pod级别的安全上下文
### 容器使用不同用户运行时共享存储卷
当一个pod中的两个容器都使用root用户运行时，他们之前可以互相读取对方的挂载卷。但是，当我们为每个容器配置其他的启动用户时，
可以会出现一些访问权限的问题。  
在kubernetes中，可以为pod中的容器指定一个supplemental组，以允许他们无论通过哪个用户启动容器都可以共享文件。
```yaml
    spec:
      securityContext:
        # 用户组id设置为555，则创建存储卷时存储卷属于用户ID为555的用户组
        fsGroup: 555
        # 定义了某个用户所关联的额外的用户组
        supplementalGroups:
          - 666
          - 777
      containers:
        - name: test-A
          image: test-container
          imagePullPolicy: IfNotPresent
          securityContext:
            runAsUser: 01
          volumeMounts:
            - mountPath: /volume
              name: test-volume
              readOnly: false
        - name: test-B
          image: test-container
          imagePullPolicy: IfNotPresent
          securityContext:
            runAsUser: 02
          volumeMounts:
            - mountPath: /volume
              name: test-volume
              readOnly: false
      volumes:
        - name: test-volume
          emptyDir: {}
```
在pod级别指定fsGroup与supplementalGroups属性，然后分别指定两个容器的启动用户为01、02。然后在启动容器，在容器中执行`id`命令
可以查看容器的用户和用户组，然后就可以看到两个容器虽然用户不同，但是都属于“555、666、777”这三个组中。
## 统一限制pod的安全相关特性 PodSecurityPolicy
PodSecurityPolicy在kubernetes中简称为psp，主要定义了用户能否在pod中使用各种安全相关的特性。  
当有人调用api server创建pod时，PodSecurityPolicy会拿到这个pod的信息与自己个规则做比较。如果符合规则，就运行其存入etcd；否则会被拒绝。
因为是在创建pod时校验的，所以修改psp，不会对已创建的pod采取措施。也可以设置默认值，就是用psp中配置的默认值替换掉pod中的值。  
主要提供了以下能力：
- 是否允许pod使用宿主节点的PID、IPC、网络命名空间
- pod允许绑定的宿主节点端口
- 容器运行时允许使用的用户ID
- 是否允许拥有特权模式容器的pod
- 允许添加哪些内核功能， 默认添加哪些内核功能， 总是禁用哪些内核功能
- 允许容器使用哪些 SELinux 选项 
- 容器是否允许使用可写的根文件系统
- 允许容器在哪些文件系统组下运行
- 允许pod使用哪些类型的存储卷  
以下为demo：
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: exporter-node-cluster-monitoring
spec:
  allowPrivilegeEscalation: false
  # 强制使用只读的根文件系统
  readOnlyRootFilesystem: true
  # 不允许使用特权方式运行容器
  privileged: false
  allowedHostPaths:
    - pathPrefix: /
      readOnly: true
  # 指定容器可以使用的用户组id范围
  fsGroup:
    ranges:
      - max: 65535
        min: 1
    rule: MustRunAs
  supplementalGroups:
    ranges:
      - max: 65535
        min: 1
    rule: MustRunAs
  # 允许使用宿主机的网络命名空间
  hostNetwork: true
  # 允许使用宿主机的PID
  hostPID: true
  # 允许使用宿主机的IPC
  hostIPC: true
  # 只允许绑定宿主机的9796端口，和1000~1080的端口
  hostPorts:
    - max: 9796
      min: 9796
    - max: 1000
      min: 1080
  # 可以使用任意用户运行
  runAsUser:
    rule: RunAsAny
  # 可以使用seLinux的任意规则
  seLinux:
    rule: RunAsAny
  # 支持的挂载方式
  volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
    - hostPath
```
#### 配置允许、默认添加、禁用内核功能
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: exporter-node-cluster-monitoring
spec:
  # 允许容器添加SYS_TIME功能
  allowedCapabilities:
    - SYS_TIME
  # 为每个容器添加CHOWN能力
  defaultAddCapabilities:
    - CHOWN
  # 要求容器禁用SYS_ADMIN和SYS_MODULE
  requiredDropCapabilities:
    - SYS_ADMIN
    - SYS_MODULE
```
### 利用RBAC分配PodSecurityPolicy
psp属于集群级别的资源，所以默认是作用于整个集群的。但是我们有时候只需要针对某些应用采用这些设置。可以通过创建一个ClusterRole然后将其
指向一个psp，再通过使用ClusterRoleBinding到不同的用户，这样的话这个psp的规则就只作用于这个用户创建的pod了。
```bash
kubectl create clusterrole psp -privileged --verb=use  --resource=podsecuritypolicies --resource-name=privileged
```
注意：这里的verb采用的是use  
然后再将这个clusterrole绑定到用户或者用户组上就可以了
## pod间的访问隔离
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: networkPolicy-demo
spec:
  # 允许可以访问哪些pod
  # 当标签中为空时，表示不允许任何pod访问
  podSelector:
```
配置同一命名空间(foo)下的相互访问权限
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: networkPolicy-demo
  namespace: foo  
spec:
  # 允许哪些pod可以访问当前命名空间中的pod
  podSelector:
    matchLabels:
      app: mysql
  ingress:
    - from:
        # 允许哪个pod可以访问
        - podSelector:
            matchLabels:
              app: service-a
    # 允许被访问的pod
    - ports:
        - 3306
```
配置跨命名空间的访问权限
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: networkPolicy-demo
  namespace: foo
spec:
  # 允许哪些pod可以访问当前命名空间中的pod
  podSelector:
    matchLabels:
      app: service-b
  ingress:
    - from:
        # 允许带有标签为（tenant=service-a）的命名空间中的pod访问
        - namespaceSelector:
            matchLabels:
              tenant: service-a
    - ports:
        - 80
```
可以通过网段限制进入的流量
```yaml
  ingress:
    - from:
        # 值允许来自ip端为192.168.1.0/24的流量
        - ipBlock:
            cidr: 192.168.1.0/24
    - ports:
        - 3306
```
限制pod流出流量
```yaml
spec:
  podSelector:
    matchLabels:
      app: service-b
  egress:
    - to:
       # 只允许流量流出到标签为（app=service-c）的pod
        - podSelector:
            matchLabels:
              app: service-c
```
