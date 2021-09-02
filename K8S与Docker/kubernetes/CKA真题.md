# CKA真题解析
1、Set configuration context $kubectl config use-context k8s. Monitor the logs of Pod foobar and Extract log lines corresponding to error unable-to-access-website . Write them to /opt/KULM00612/foobar.
翻译：设置配置上下文$kubectl config use context k8s，监控Pod foobar的日志，并提取错误“unable-to-access-website”对应的日志行。把它们写到/opt/KULM00612/foobar。
解析：就是看下一个pod中的日志，把满足条件的日志行保存在某一文件中
--------------------------------------------------------------------------------------
kubectl config use-context k8s
kubectl logs foobar | grep 'unable-to-access-website' > opt/KULM00612/foobar
检查：
kubectl logs foobar    #考试时这个pod输出很少，就7，8行，你可以看到你要的日支行，就一行满足条件
cat opt/KULM00612/foobar  #看下结果，核对下

2、Set configuration context $kubectl config use-context k8s. List all PVs sorted by capacity, saving the full kubectl output to /opt/KUCC0006/my_volumes. Use kubectl own functionally for sorting the output, and do not manipulate it any further
翻译：设置配置上下文$kubectl config use context k8s。列出按容量排序的所有PV，将完整的kubectl输出保存到/opt/KUCC0006/my_volumes。在功能上使用kubectl 本身对输出进行排序，不要再对其进行任何操作
解析：pv排序
--------------------------------------------------------------------------------------
kubectl config use-context k8s
kubectl get pv -A --sort-by={.spec.capacity.storage} > /opt/KUCC0006/my_volumes
注意看下，他是要所有的PV，所以-A是所有命名空间
命令怎么查？
kubectl get pv --help

3、Set configuration context $kubectl config use-context k8s. Ensure a single instance of Pod nginx is running on each node of the Kubernetes cluster where nginx also represents the image name which has to be used. Do no override any taints currently in place. Use Daemonset to complete this task and use ds.kusc00612 as Daemonset name
翻译：设置配置上下文$kubectl config use context k8s。确保在Kubernetes集群的每个节点上运行Pod nginx的单个实例，其中nginx还表示必须使用的映像名称。不要覆盖当前存在的任何污点。使用Daemonset完成此任务并使用ds.kusc00612作为守护进程名称
解析：考察DaemonSet,不需要容忍某些节点的污点
--------------------------------------------------------------------------------------
参考网址：https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
kubectl config use-context k8s
```
vi ds.kusc00612.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds.kusc00612
  labels:
    k8s-app: ds.kusc00612
spec:
  selector:
    matchLabels:
      name: ds.kusc00612
  template:
    metadata:
      labels:
        name: ds.kusc00612
    spec:
      containers:
      - name: nginx
        image: nginx
```
运行后看下，一般不是所有节点都有这个pod的，因为有些节点上有污点，你可以使用以下命令看下有几个节点是有污点：
```
kubectl describe nodes | grep Taints
```
一般有几个节点就会输出几行，没污点的节点所在行是空的。然后用kubectl get nodes看下哪个节点是有污点。然后kubectl get po -o wide| grep 0612.看下确实的节点是不是有污点的节点。以此可做检查。

4、Set configuration context $kubectl config use-context k8s Perform the following tasks: Add an init container to lumpy-koala(which has been defined in spec file /opt/kucc00100/pod-specKUCC00612.yaml). The init container should create an empty file named /workdir/calm.txt. If /workdir/calm.txt is not detected, the Pod should exit. Once the spec file has been updated with the init container definition, the Pod should be created
翻译：执行以下任务：将init容器添加到lumpy-koala（已在文件/opt/kucc00100/pod-specKUCC00612.yaml中定义）。init容器应该创建一个名为/workdir/calm.txt的空文件. 如果/workdir/calm.txt未检测到，Pod应退出。一旦用init容器定义更新了spec文件，就应该创建Pod
解析：这道题在/opt/kucc00100/pod-specKUCC00612.yaml路径下已经有写好的Yaml了，但是还未在集群中创建该对象。所以你上去最好先kubectl get po | grep pod名字。发现集群还没有该pod。所以你就先改下这个Yaml,然后apply.先创建Initcontainer,然后在里面创建文件，/workdir目录明显是个挂载进度的目录，题目没规定，你就定义empDir类型。这边还要用到liveness检查。
--------------------------------------------------------------------------------------
参考网址：
https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#using-init-containers
https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
kubectl config use-context k8s
```
在pod-specKUCC00612.yaml后面添加
  initContainers:
  - name: init-container
    image: busybox
    command: ['sh', '-c', "touch /workdir/calm.txt"]
    volumeMounts:
    - mountPath: /workdir
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```
kubectl apply -f xxx.yaml
kubectl get po | grep KUCC00612
running后
使用：kubectl exec -ti KUCC00612 -- ls /workdir
看下有没有calm.txt以做检查

5、Set configuration context $kubectl config use-context k8s. Create a pod named kucc6 with a single container for each of the following images running inside(there may be between 1 and 4 images specified):nginx +redis+memcached+consul。
翻译：创建一个名为kucc6的pod，其中包含运行在其中的以下映像的单个容器（可能会指定1到4个映像）：nginx+redis+memcached+consur
解析：创建pod，有四个镜像
--------------------------------------------------------------------------------------
参考网址：https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
kubectl config use-context k8s
```
vi kucc6.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kucc6
  labels:
    env: kucc6
spec:
  containers:
  - name: nginx
    image: nginx
  - name: redis
    image: redis
  - name: memcached
    image: memcached
  - name: consul
    image: consul
```
kubectl apply -f xx.yaml
kubeget get po

6、Set configuration context $kubectl config use-context k8s Schedule a Pod as follows: Name: nginxkusc00612 Image: nginx Node selector: disk=ssd
翻译：创建 Pod，名字为 nginx，镜像为 nginx，部署到 label disk=ssd的node上
解析：pod调度到指定节点，Nodeselector
--------------------------------------------------------------------------------------
官网搜索nodeselector找yaml文件
kubectl config use-context k8s
```
apiVersion: v1
kind: Pod
metadata:
  name: nginxkusc00612
  labels:
    app: nginxkusc00612
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```
kubectl apply -f nginxkusc00612.yaml
kubectl get po -o wide | grep nginxkusc00612 看一下所属节点
kubectl get nodes --show-labels | grep disk  出来的节点看下是不是上面查出来的节点。集群中节点一般就3个，很容易看的。

7、Set configuration context $kubectl config use-context k8s. Create a deployment as follows: Name: nginxapp Using container nginx with version 1.11.9-alpine. The deployment should contain 3 replicas. Next, deploy the app with new version 1.12.0-alpine by performing a rolling update and record that update.Finally,rollback that update to the previous version 1.11.9-alpine.
解析：部署deploy,然后修改进镜像（滚动更新），然后回滚上一版本
--------------------------------------------------------------------------------------
官网搜索Deployment
kubectl config use-context k8s
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginxapp
  labels:
    app: nginxapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.11.9-alpine
        ports:
        - containerPort: 80
```
kubectl apply -f nginxapp.yaml
kubectl set image deployment/nginxapp nginx=nginx:1.12.0-alpine --record=true #--record加上，现在这样就是滚动更新了
kubectl rollout history deployment/nginxapp 看下滚动历史
然后执行 kubectl rollout undo deployment/nginxapp
就完成了，记不住命令没有关系，kubectl set image --help查看，kubectl rollout --help查看。

8、Set configuration context $kubectl config use-context k8s Create and configure the service front-endservice so it’s accessible through NodePort/ClusterIp and routes to the existing pod named front-end
解析：创建service，指定后端到已有pod: front-end
--------------------------------------------------------------------------------------
先查看下front-end的Pod是否存在
kubectl get po | grep front-end
看下front-end的镜像，kubectl get po -o yaml | grep image.我看到是nginx，那后面就可以用来检查了。然后看下label，后面service的selector需要用到
只要写个service就够了
参考网址：https://kubernetes.io/docs/tasks/access-application-cluster/connecting-frontend-backend/
kubectl config use-context k8s
```
apiVersion: v1
kind: Service
metadata:
  name: front-end-service
spec:
  selector:
    app: front-end #这边的标签一定要和front-end的Label一致
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
```
kubectl apply -f xxx.yaml
检查：
kubectl get nodes
ssh nodename
culr serviceIp:80 
出来nginx的欢迎页，就没啥问题了

9、Set configuration context $kubectl config use-context k8s Create a Pod as follows: Name: jenkins Using image: jenkins In a new Kubernetes namespace named pro-test
解析：在新的命名空间中创建jenkins的pod
--------------------------------------------------------------------------------------
kubectl config use-context k8s
```
看下pro-test命名空间是否存在，一般是不存在
kubectl get ns | grep pro-test
kubectl create ns pro-test
官网搜索Pod
然后增加namespace字段:
```
apiVersion: v1
kind: Pod
metadata:
  name: jenkins
  namespace: pro-test
  labels:
    env: jenkins
spec:
  containers:
  - name: jenkins
    image: jenkins
```
kubectl apply -f xx.yaml
kubectl get po -n pro-test | grep jenkins

10、Set configuration context $kubectl config use-context k8s Create a deployment spec file that will: Launch 7 replicas of the redis image with the label : app_enb_stage=dev Deployment name: kual00612 Save a copy of this spec file to /opt/KUAL00612/deploy_spec.yaml (or .json) When you are done,clean up(delete) any new k8s API objects that you produced during this task
翻译：设置配置上下文$kubectl config use context k8s创建一个部署规范文件，该文件将：启动redis映像的7个副本，标签为：app_enb_stage=dev deployment name:kual00612将此规范文件的副本保存到/opt/kual00612/deploy_spec.yaml（或.json）完成后，清理（删除）您在此任务期间生成的任何新的k8sapi对象
解析：创建7副本的redis的deploy，指明标签，然后把yaml保存在指定位置
--------------------------------------------------------------------------------------
参考网址:https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
kubectl config use-context k8s
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kual00612
  labels:
    app_enb_stage: dev
spec:
  replicas: 7
  selector:
    matchLabels:
      app: kual00612 #标签最好都用deployment的名字
  template:
    metadata:
      labels:
        app: kual00612
    spec:
      containers:
      - name: redis
        image: redis
```
kubectl apply -f xx.yaml
kuectl get po | grep kual00612   running就ok了
然后kubectl delete -f xx.yaml 题目要求删除该资源
cat xx.yaml > /opt/KUAL00612/deploy_spec.yaml
cat /opt/KUAL00612/deploy_spec.yaml  #检查看下

11、Set configuration context $kubectl config use-context k8s Create a file /opt/KUCC00612/kucc00612.txt that lists all pods that implement Service foo in Namespace production. The format of the file should be one pod name per line.
解析：满足foo service选择规则的pod，并把名字写入某个文件
--------------------------------------------------------------------------------------
kubectl config use-context k8s
```
kubectl get svc -n production #看下foo在不在
kubectl get svc -n production -o yaml | grep selector
一定要看selector的label而不是service的label。selector的label才是选个后端pod的label。然后看到Label是app=blog.
kubectl get po -n production -l app=blog | grep -v NAME | awk '{print $1}' >/opt/KUCC00612/kucc00612.txt
看下是不是pod名称 cat /opt/KUCC00612/kucc00612.txt

12、Set configuration context $kubectl config use-context k8s Create a Kubernetes Secret as follows: Name: super-secret credential: blob, Create a Pod named pod-secrets-via-file using the redis image which mounts a secret named super-secret at /secrets. Create a second Pod named pod-secretsvia-env using the redis image, which exports credential as 
翻译：创建一个Kubernetes Secret，如下所示：Name:super Secret credential:blob，使用redis映像创建一个名为Pod secrets的Pod，该映像在/secrets处挂载一个名为super Secret的机密。使用redis映像创建第二个名为Pod secretsvia env的Pod，它将凭证导出为凭证
解析：创建secret，并在pod中通过Volume和环境变量使用该secret
--------------------------------------------------------------------------------------
参考网址：https://kubernetes.io/zh/docs/concepts/configuration/secret/
kubectl config use-context k8s
```
对blob进行base64编码，然后才能放入secret
echo -n 'blob' | base64
```
创建yaml：
```
apiVersion: v1
kind: Secret
metadata:
  name: super-secret
type: Opaque
data:
  credential: YWRtaW4=
```
kubectl apply -f secret.yaml
创建pod:pod-secrets-via-file
```
apiVersion: v1
kind: Pod
metadata:
  name: pod-secrets-via-file
spec:
  containers:
  - name: pod-secrets-via-file
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/secrets"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: super-secret
```
kubectl apply -f pod-secrets-via-file.yaml
创建pod:pod-secretsvia-env
```
apiVersion: v1
kind: Pod
metadata:
  name: pod-secretsvia-env
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: supersecret
            key: username
      - name: CREDENTIAL
        valueFrom:
          secretKeyRef:
            name: supersecret
            key: credential
  restartPolicy: Never
```
kubectl apply -f pod-secretsvia-env.yaml
检验：
kubectl exec -ti pod-secretsvia-env -- env ##会打印出很多环境变量，看下你定义的在不在，最后进pod: echo $CREDENTIAL 确认下结果
kubectl exec -ti pod-secrets-via-file -- ls /secrets

13、Set configuration context $kubectl config use-context k8s Create a pod as follows: Name: nonpersistent-redis Container image: redis Named-volume with name: cache-control Mount path : /data/redis It should launch in the pre-prod namespace and the volume MUST NOT be persistent.
解析：创建一个pod，并挂载volume
--------------------------------------------------------------------------------------
官网搜索volume
kubectl config use-context k8s
```
apiVersion: v1
kind: Pod
metadata:
  name: nonpersistent-redis
spec:
  containers:
  - image: redis
    name: redis
    volumeMounts:
    - mountPath: /data/redis
      name: cache-control
  volumes:
  - name: cache-control
    emptyDir: {}
```
kubectl apply -f xxx.yaml
kubectl get po | grep nonpersistent。看下是不是running
kubectl exec -ti nonpersistent-redis -- ls /data    看下是否有redis目录

14、Set configuration context $kubectl config use-context k8s Scale the deployment webserver to 6 pods
解析：扩缩容
--------------------------------------------------------------------------------------
kubectl config use-context k8s
kubectl get deployment | grep webserver  看下是否存在
运行kubectl scale --help,查看例子
kubectl scale deploymnet/webserver --replicas=6

15、Set configuration context $kubectl config use-context k8s Check to see how many nodes are ready (not including nodes tainted NoSchedule) and write the number to /opt/nodenum.
解析：有多少节点是ready状态的，不包含被打了NoSchedule污点的节点
--------------------------------------------------------------------------------------
kubectl config use-context k8s
kubectl get nodes看下ready的个数M，
kubectl describe nodes | grep Taints，看下打印出来的污点是否有NoSchedule。看下NoSchedule行数N.
number=M-N 将数字保存在/opt/nodenum文件中

16、Set configuration context $kubectl config use-context k8s From the Pod label name=cpu-utilizer, find pods running high CPU workloads and write the name of the Pod consuming most CPU to the file /opt/cpu.txt (which already exists).
解析：题目意思是从label是name=cpu-utilizer的pod中找出使用cpu最高的Pod,并把pod的Name写入/opt/cpu.txt。
--------------------------------------------------------------------------------------
kubectl config use-context k8s
kubectl top --help   查看top的使用
kubectl top pod -l name=cpu-utilizer  应该会出来多个满足条件的Pod,查看pod的cpu小号字段最高的，然后将其名字写入/opt/cpu.txt

17、Set configuration context $kubectl config use-context k8s Create a deployment as follows: Name: nginxdns Exposed via a service : nginx-dns Ensure that the service & pod are accessible via their respective DNS records The container(s) within any Pod(s) running as a part of this deployment should use the nginx image. Next, use the utility nslookup to look up the DNS records of the service & pod and write the output to /opt/service.dns and /opt/pod.dns respectively. Ensure you use the busybox:1.28 image (or earlier) for any testing, an the latest release has an upstream bug which impacts the use of nslookup
解析：创建service和deployment，然后解析service的dns和pod的dns，并把解析记录保存到指定文件
--------------------------------------------------------------------------------------
参考网址:https://kubernetes.io/docs/tasks/access-application-cluster/connecting-frontend-backend/
kubectl config use-context k8s
```
vi deployment.yaml:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginxdns
spec:
  selector:
    matchLabels:
      app: nginxdns
  replicas: 1
  template:
    metadata:
      labels:
        app: nginxdns
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - name: http
              containerPort: 80
```
vi service.yaml:
apiVersion: v1
kind: Service
metadata:
  name: ngixdns
spec:
  selector:
    app: nginxdns
  ports:
  - protocol: TCP
    port: 80
    targetPort: http
```
https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
vi busybox.yaml:
apiVersion: v1
kind: Pod
metadata:
  name: busybox-test
  labels:
    app: busybox-test
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600'] #sleep 3600一定要啊，不然busybox运行后直接退出
```
kubectl apply -f busybox.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl exec -ti busybox-test -- nslookup nginx-dns > /opt/service.dns
kubectl exec -ti busybox-test -- nslookup podup > /opt/pod.dns

18、No configuration context change required for this item Create a snapshot of the etcd instance running at https://127.0.0.1:2379 saving the snapshot to the file path /data/backup/etcd-snapshot.db The etcd instance is running etcd version 3.2.18 The following TLS certificates/key are supplied for connecting to the server with etcdctl CA certificate: /opt/KUCM0612/ca.crt Client certificate: /opt/KUCM00612/etcdclient.crt Client key: /opt/KUCM00612/etcd-client.key
解析：备份etcd，手册中有该命令，需要指定证书的话，看下etcdctl --help
--------------------------------------------------------------------------------------
参考网址：https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster
需要指定证书，所以你使用etcdctl --help查看下证书相关的字段
```
export ETCDCTL_API=3
etcdctl snapshot save --help
etcdctl --endpoints= https://127.0.0.1:2379 --cert="/opt/KUCM000613/etcd-client.crt" --
cacert="/opt/KUCM00612/ca.crt" --key="/opt/KUCM00612/etcd-client.key" snapshot save
/data/backup/etcd-snapshot.db
```
接着既可以检查下你备份的文件：
```
ETCDCTL_API=3 etcdctl --write-out=table snapshot status /data/backup/etcd-snapshot.db
有以下输出，就没问题
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| fe01cf57 |       10 |          7 | 2.1 MB     |
+----------+----------+------------+------------+
```

19、Set configuration context $kubectl config use-context ek8s Set the node labelled with name=ek8s-node-1 as unavailable and reschedule all the pods running on it.
解析：将标签未name=ek8s-node-1设置成不可用且把这个节点上面的pod调度到其他节点上去。其实就是使用kubectl drain命令
--------------------------------------------------------------------------------------
kubectl config use-context ek8s # 切换集群
kubectl get node --show-labels | grep name=ek8s-node-1
kubectl get pods -o wide | grep ek9s-node-1
kubectl cordon  ek9s-node-1 # 先设置为cordon不让其再被调度，就是不再让其有pod，保证下面删除有效.这步考试时我没执行，我觉得不影响，是没人在我操作时操作集群的
kubectl drain  ek9s-node-1 --ignore-daemonsets
kubectl get nodes查看下 ek9s-node-1这个节点会有unschedule的标记
```
20、Set configuration context $kubectl config use-context wk8s A Kubernetes worker node,labelled with name=wk8s-node-0 is in state NotReady. Investigate why this is the case, and perform any appropriate steps to bring the node to a Ready state, Ensuring that any changes are made permanent. Hints: You can ssh to the failed node using $ssh wk8s-node-0. You can assume elevated privileges on the node with the following command $sudo -i
题目解析：wk8s-node-0是NotReady状态，你需要处理下，使其变为ready，别更改需要永久性
--------------------------------------------------------------------------------------
kubectl config use-context wk8s
kubectl get nodes #发现wk8s-node-0是NotReady状态
ssh wk8s-node-0
sudo -i
systemctl status kubelet  #发现没启动
systemctl start kubelet
systemctl enable kubelet
exit #从root切到user
exit #从wk8s-node-0回到Master节点
kubectl get nodes # 发现wk8s-node-0是ready状态了
```

21、Set configuration context $kubectl config use-context wk8s Configure the kubelet system managed service,on the node labelled with name=wk8s-node-1, to Launch a Pod containing a single container of image nginx named myservice automatically. Any spec files required should be placed in the /etc/kubernetes/manifests directory on the node. Hints: You can ssh to the failed node using $ssh wk8snode-1. You can assume elevated privileges on the node with the following command $sudo -i
题目解析：考察的是静态Node
--------------------------------------------------------------------------------------
参考网址：https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/
kubectl config use-context wk8s
ssh wk8s-node-1
cd  /etc/kubernetes/manifests
vi pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: myservice
  labels:
    role: myrole
spec:
  containers:
    - name: web
      image: nginx
      ports:
        - name: web
          containerPort: 80
          protocol: TCP
```
kubelet照理来说会轮询检查 /etc/kubernetes/manifests下是否有yaml，有的话就会创建为静态pod
```
systemctl status kubelet
下面是打印出来的东西：
● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; vendor preset: disabled)
  Drop-In: /usr/lib/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: active (running) since 六 2020-04-18 20:44:33 CST; 1 months 30 days ago
     Docs: https://kubernetes.io/docs/
 Main PID: 21185 (kubelet)
    Tasks: 23
   Memory: 106.9M
   CGroup: /system.slice/kubelet.service
           └─21185 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kuber...

6月 18 07:04:16 master1 kubelet[21185]: W0618 07:04:16.392108   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:04:46 master1 kubelet[21185]: W0618 07:04:46.511713   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:09:36 master1 kubelet[21185]: W0618 07:09:36.698768   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:09:36 master1 kubelet[21185]: W0618 07:09:36.698947   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:17:36 master1 kubelet[21185]: W0618 07:17:36.324375   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:17:36 master1 kubelet[21185]: W0618 07:17:36.324500   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:17:36 master1 kubelet[21185]: W0618 07:17:36.324554   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:17:46 master1 kubelet[21185]: W0618 07:17:46.644361   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:17:46 master1 kubelet[21185]: W0618 07:17:46.644439   21185 watcher.go:87] Error while processing event ...ectory
6月 18 07:29:26 master1 kubelet[21185]: W0618 07:29:26.400216   21185 watcher.go:87] Error while processing event ...ectory
Hint: Some lines were ellipsized, use -l to show in full.
```
查看kubelet启动配置文件的内容：
cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
```
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/sysconfig/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS

```
发现里面并没有KUBELET_ARGS参数后面没有指定pod-manifest-path参数，类似这样KUBELET_ARGS="--cluster-dns=10.254.0.10 --cluster-domain=kube.local --pod-manifest-path= /etc/kubernetes/manifests"
然后只能去看下KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml 这个参数指定的yaml里看下有没有指定静态pod的指定路径，要是也没有的话，kubelet是不会自动创建静态Pod的，而且pod-manifest-path没有默认值。
cat /var/lib/kubelet/config.yaml
```
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 0s
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
```
发现没有指定静态Pod路径的参数，在最后添加staticPodPath: /etc/kubernetes/manifests
然后运行：
```
systemctl restart kubelet
systemctl enable kubelet
```
然后去Master节点上看下，发现静态pod起来了，那就ok了

22、这题是给你两个节点，master1和node1，和一个admin.conf文件，然后让你在这两个节点上部署集群。
解析：
--------------------------------------------------------------------------------------
官网文档(https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#%E5%AE%89%E8%A3%85-kubeadm-kubelet-%E5%92%8C-kubectl)  
sudo apt-get update && sudo apt-get install -y apt-transport-https curl  
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -  
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list  
deb https://apt.kubernetes.io/ kubernetes-xenial main  
EOF  
sudo apt-get update  
sudo apt-get install -y kubelet kubeadm kubectl  
sudo apt-mark hold kubelet kubeadm kubectl
```
官网文档（https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node）  
```
kubeadm init --config /etc/kubeadm.conf ignore-preflight-errors=all  #忽略错误参数和配置文件都有提供，配置文件不用改，注意审题！
```
官网文档(https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network)  
```
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
```
看下kubectl get nodes是否ready，看下Kube-system命名空间下pod是否都是running

23、Set configuration context $kubectl configuse-context bk8s Given a partially-functioning Kubernetes cluser, identify symptoms of failure on the cluter. Determine the node, the failing service and take actions to bring up the failed service and restore the health of the cluser. Ensure that any changes are made permanently. The worker node in this cluster is labelled with name=bk8s-node-0 Hints: You can ssh to the relevant nodes using $ssh $(NODE) where $(NODE) is one of bk8s-master-0 or bk8s-node-0. You can assume elevated privileges on any node in the cluster with the following command: $ sudo -i.
解析：这题的意思是，有个集群部分功能出现问题，需要你去修一下，需要是永久性的修复。
--------------------------------------------------------------------------------------
kubectl configuse-context bk8s
ssh bk8s-master-0
sudo -i
kubectl get po    !!!竟然长时间没有返回，我觉得apiserver挂了
systemctl status kube-apiserver.service ！！！发现没有
ps -ef | grep apiserver !!! 也没有，所以应该不是本地部署的，应该走的是静态pod的部署方式。
kubectl get po -A | grep apiserver  !!!也没有？master节点上没有apiserver，所以问题肯定处在apiserver没有启动。接着我检查下/etc/kubernetes/manifests,一般静态pod都会放在这个目录下，要是没有，就去查看下Kubelet的配置文件
ls /etc/kubernetes/manifests   ###发现apiserver,controllermanager的yaml都在这里。
按21题的方式查看下kubelet的配置，发现静态Pod的路径没配置，就按21题的方式配置好,即在kubelet配置文件中添加staticPodPath: /etc/kubernetes/manifests（说明下可以在两个地方配置这个参数，一个是kubectl.service的配置文件中的KUBELET_ARGS="--cluster-dns=10.254.0.10 --cluster-domain=kube.local --pod-manifest-path= /etc/kubernetes/manifests，一个是KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml 的yaml文件中）
systemctl restart kubelet
systemctl enable kubelet
```
发现apiserver的pod起来了，kubectl get pod可以正常返回来。

kubectl get nodes都是ready状态

24、Set configuration context $kubectl config use-context hk8s Create a persistent volume with name appconfig of capacity 1Gi and access mode ReadWriteMany. The type of volume is hostPath and its locationis /srv/app-config
解析：官网搜索persistent volume
--------------------------------------------------------------------------------------
apiVersion: v1
kind: PersistentVolume
metadata:
  name: appconfig
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /srv/app-config
```
kubectl apply -f xx.yaml
kubectl get pv 看下这个pv,status是available的就可以了。