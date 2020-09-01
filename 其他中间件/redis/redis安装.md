### 容器版 
1. docker加载镜像文件
```bash
docker load -i ecs-redis.tar
```
2. 查看本地镜像
```bash
docker images | grep ecs-redis
```  
得到如下结果,则镜像已经加载完毕
```bash
ecs-redis                                       6.0                    50541622f4f1        7 days ago          104MB
```
3. 启动redis容器
需要提前在宿主机创建好文件夹地址`/root/docker/redis/data`
```bash
docker run -d --name ecs-redis -p 6379:6379 -v /root/docker/redis/data:/data --restart=always ecs-redis:6.0 --appendonly yes
```
- -d：容器后台启动
- --name：给容器命名
- -p：宿主机端口：容器内部端口
-  --restart：容器停止后重启策略
- -v：挂载redis数据
- --appendonly yes 开启数据持久化  

 查询容器是否启动成功  
 ```bash
docker ps -a | grep ecs-redis
```  
得到如下结果
```bash
c9cb9843558d        ecs-redis:6.0            "docker-entrypoint.s…"   12 seconds ago      Up 11 seconds              0.0.0.0:6379->6379/tcp                     ecs-redis
```

