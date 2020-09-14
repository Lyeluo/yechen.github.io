## 下载镜像
docker pull openjdk:8
## 执行命令
~~~bash
docker run -d -p 9001:8081 -v /opt/springboot-docker-1.0.jar:/var/lib/docker/jar/springboot-docker-1.0.jar --name ecs-console java:8u111 java -jar /var/lib/docker/jar/springboot-docker-1.0.jar

# -d 表示在后台启动
# -p 8081:8080 表示将容器的端口 映射成宿主主机的端口，否则8080端口访问不到
# -v /opt/springboot-docker-1.0.jar:/var/lib/docker/jar/springboot-docker-1.0.jar
# 表示将宿主主机的jar文件，映射到容器中（分号前为宿主主机的路径就是服务器的路径，分号后为容器中的路径）
# --name ecs-console
# 表示为该容器取一个全局唯一的名称，这里我取的名称为ecs-console
# java:8u111 表示镜像文件的名称和tag
# java -jar /var/lib/docker/jar/springboot-docker-1.0.jar
# 表示运行jar包，注意：这里的jar包为容器中的位置，是通过前面的-v属性映射的
~~~
## 完整的脚本
~~~bash
#!/usr/bin/env bash
docker pull openjdk:8
#判断容器是否存在
docker ps -a | grep ecs-console &> /dev/null
if [ $? -ne 0 ]; then
    docker run -d -p 9001:8081  -v /home/docker/ecs/timezone:/etc/timezone -v /etc/localtime:/etc/localtime -v /home/docker/ecs/console/ecs-console.jar:/ecs-console.jar --name ecs-console openjdk:8 java -Xmx1024m -Xms1024m -XX:MaxMetaspaceSize=256M -XX:MetaspaceSize=256M -Dfile.encoding=utf-8 -jar /ecs-console.jar
else
   docker restart ecs-console
fi

~~~

