## Docker命令
构建Docker镜像应该遵循哪些原则？
```bash
#整体远侧上，尽量保持镜像功能的明确和内容的精简，要点包括： 
    # 尽量选取满足需求但较小的基础系统镜像，建议选择alpine:latest镜像，仅有2MB左右 
    # 清理编译生成文件、安装包的缓存等临时文件 
    # 安装各个软件时候要指定准确的版本号，并避免引入不需要的依赖 
    # 从安全的角度考虑，应用尽量使用系统的库和依赖 
    # 使用Dockerfile创建镜像时候要添加.dockerignore文件或使用干净的工作目录
```
1.删除悬空镜像（镜像名称或者tag为空的镜像）  
```docker rmi $(docker images -f "dangling=true" -q)```  
docker启停
```bash
#启动docker
service docker start
#停止docker
service docker stop
#重启docker
service docker restart
systemctl enable docker
```
查看容器中的启动配置，得到一个json文件
```bash
docker inspect ecs
```

docker 配置login harbor
```bash
vim /usr/lib/systemd/system/docker.service

```
运行完毕后自动清理镜像  
这将从“ubuntu”映像创建一个容器，显示/ etc / hosts文件的内容，然后在它退出后立即删除容器。这有助于防止在完成实验后必须清理容器。
```bash
docker run --rm ubuntu cat /etc/hosts
```
清理所有无用镜像.这招要慎用，否则需要重新下载。  
```bash
docker image prune -a -f
#可以增加过滤条件，如根据创建时间删除
docker image prune -a --force --filter "until=312h"
```
7. 清理已经退出的容器
```bash
docker container prune --force
```
根据容器名称匹配停止容器，删除容器
```bash
docker stop  `docker ps -aq --filter image=harbor*`
docker rm    `docker ps -aq --filter name=rmq*`
```
根据镜像名称匹配停止容器，删除容器
```bash
# 这里好像不能用通配符
docker stop  `docker ps -aq --filter ancestor=rancher/rancher-agent:v2.4.2`
docker rm    `docker ps -aq --filter ancestor=rancher/rke-tools:v0.1.56` -f
```
根据名称匹配删除镜像
```bash
docker image rm `docker images -q --filter reference=zabbix/zabbix*`

```
copy 容器中的文件到宿主机
```bash
docker cp mycontainer:/opt/testnew/file.txt /opt/test/
```
mycontainer:容器名称
/opt/testnew/file.txt：容器中的文件
/opt/test/：宿主机的路径
2.进入容器
```
docker exec -it 容器id /bin/bash
```
3. 创建容器
```
 docker build -t 容器名:容器tag .
. 表示当前文件夹下的Dockerfile文件
```
4. 运行容器
```
docker run -it -p 32001:8080 console:1.0
32001:映射到宿主机上的ip地址
8080：Dockerfile里面释放的地址
console：容器名称
1.0：容器tag
```
5. 从容器中copy文件到宿主机
```
docker cp 7ec8d55dcc43:/usr/local/tomcat/bin/catalina.sh ./catalina.sh
7ec8d55dcc43: 容器id
/usr/local/tomcat/bin/catalina.sh：容器中文件的全路径
./catalina.sh：宿主机文件的相对路径
```
6.查看日志
```bash
docker logs --tail=100 -f 容器id 
```

8. 过滤查询容器
```bash
docker ps -a --filter 'exited=0'
```
9. 根据运行中容器创建镜像  
将一个正在运行中的容器做成镜像
```bash
docker commit 当前运行的容器名 新镜像名:版本号
```
10. docker volume命令
```bash
Usage:	docker volume COMMAND

Manage volumes

Commands:
  create      Create a volume
  inspect     Display detailed information on one or more volumes
  ls          List volumes
  prune       Remove all unused local volumes
  rm          Remove one or more volumes
```
删除所有挂载卷
```bash
docker volume rm $(sudo docker volume ls -q)
```
根据一个容器的挂载文件创建另一个容器，只是为了挂载使用
```bash
docker create --volumes-from <RANCHER_CONTAINER_NAME> --name rancher-data rancher/rancher:<RANCHER_CONTAINER_TAG>
```
使用之前的挂载容器,获取容器的挂载文件作为新容器的挂载文件
```bash
docker run -d --privileged --volumes-from rancher-data \
  --restart=unless-stopped \
  -p 80:80 -p 443:443 \
    rancher/rancher:<RANCHER_VERSION_TAG>
```

11.存储镜像到tar.gz
```bash
docker save danielqsj/kafka-exporter:latest | gzip > kafka-exporter.tar.gz
```
使用docker save存储的镜像 需要使用docker load加载
```bash
docker load -i kafka-exporter.tar.gz
```
11.5 存储容器到tar.gz
```bash
docker export -o kafka-exporter.tar.gz danielqsj/kafka-exporter:latest
```
使用 docker export导出的镜像，需要使用docker import导入,导入时可以重新指定镜像名称
```bash
docker import kafka-exporter.tar.gz kafka-exporter:latest
```
12.查看容器状态
```bash
# 持续输出所有容器的状态，按ctrl+c退出
docker stats
# 查看所有容器状态
docker stats --no-stream
# 查看指定容器的状态
docker stats --no-stream 容器id
# 通过json格式输出结果
docker stats --no-stream --format \
    "{\"container\":\"{{ .Container }}\",\"memory\":{\"raw\":\"{{ .MemUsage }}\",\"percent\":\"{{ .MemPerc }}\"},\"cpu\":\"{{ .CPUPerc }}\"}"
```
更多docker命令查看地址：https://docs.docker.com/engine/reference/commandline/image_prune/#filtering
## K8S命令
+ 查看节点信息 带标签
```bash
rancher kubectl get nodes --show-labels
```
+ 查看一个pod的信息，以yaml/json格式展示
```
 kubectl get po kubia-zxzij -o yaml 
 kubectl get po kubia-zxzij -o json 
```
+ 查看某个参数的定义，或者用法、参数等  
```
kubectl explain pods 
kubectl explain pod.spec 
```
+ 根据yaml文件或者json文件创建k8s对象（pod、deployment等）
```
kubect1 create -f kubia-manual.yaml 
```
+ 使用kubectl获取容器日志
```
pod中单容器
kubectl logs podname 
pod中多容器
kubectl logs podname -c contaionername
```
+ 根据标签查询pod  
```
查询包含env标签的pod
kubectl get po -l env
查询不包含env标签的pod
kubectl get po -l '!env'
题外话：标签可以被附加给任何kubernetes的对象上，包括node
```
+ 查看重启容器后的pod描述
```
## 超详细
kubectl describe po podname 
```
+ 查看指定命名空间所有的pod及信息
```bash
## 详细
kubectl get pod -o wide --namespace=ecs2
## 超详细
kubectl describe pod --namespace=ecs2
```
得到结果如下
![容器上次崩溃的原因：错误码137](../images/企业微信截图_15773468618763.png)  
+ 增加node标签,配合deploy.yml里的nodeSelector属性使用
```bash
rancher kubectl label nodes dockercontainermaster businesstype=ecs

```
+ 使用kubectl cp 文件到本地
```bash
rancher kubectl cp -c ecs-dev-lir21020101-java ecs-dev/ecs-dev-lir21020101-55b48df98c-7jb8j:app.jar app.jar
```
###
+ 在pod中执行一个sh命令
```bash
kubectl exec kubia-7nogl -- curl -s http: //10 .111. 249 .153
```
+ 在pod中执行shell脚本
```bash
kubectl exec -it kubia-3inly bash
```
暂停 deployment
```bash
kubectl rollout pause deployment nginx-deployment

```
重新部署
```bash
kubectl rollout resume deployment/nginx-deployment
```
检查deployment是否启动成功,如果上线成功完成，kubectl rollout status 返回退出代码 0。
```bash
kubectl rollout status deployment.v1.apps/nginx-deployment
```
编辑k8s的pod
```bash
# kubectl replace 根据原有资源的json/yml进行变更，会删除原有pod重新创建一个pod
# 用法如下
kubectl get pod test-85fd7c9b44-9jjqm -o yaml -n ecs-dev | sed 's/\(image: redis\):.*$/\1:5.0/' | kubectl replace --force -f -

```
