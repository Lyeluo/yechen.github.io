[[toc]]
## Docker命令
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
docker 配置login harbor
```bash
vim /usr/lib/systemd/system/docker.service

```

清理所有无用镜像.这招要慎用，否则需要重新下载。  
```bash
docker image prune -a
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
kubectl describe po podname 
```
得到结果如下
![容器上次崩溃的原因：错误码137](../images/企业微信截图_15773468618763.png)  
+ 增加node标签,配合deploy.yml里的nodeSelector属性使用
```bash
rancher kubectl label nodes dockercontainermaster businesstype=ecs

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
