### 1.拉取nginx镜像
```bash
docker pull nginx:1.18.0
```
### 2.创建目录，并copy容器中文件到本地
```bash
docker cp nginx:/etc/nginx/ ./conf/
docker cp nginx:/usr/share/nginx/ ./
```
### 3.删除容器
```bash
docker rm -f nginx
```
### 4.重新启动容器，挂载conf、html、log目录
```bash
docker run --name ecs-nginx -p 80:80 -p 9097:9097 \
-v /opt/docker/nginx/conf/nginx:/etc/nginx \
-v /opt/docker/nginx/html:/usr/share/nginx/html \
-v /opt/docker/nginx/logs/:/var/log/nginx \
-d nginx:1.18.0
```
注意：每次修改文件后，如果没有新增端口释放，执行`docker exec -it ecs-nginx nginx -s reload`加载配置；如果新增了端口，需要删除原有容器，
docker run增加端口映射重新启动
