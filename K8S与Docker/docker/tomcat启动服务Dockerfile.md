[[toc]]
## Dockerfile
```
FROM tomcat:8.5.46-jdk8-openjdk-slim
COPY ecs-console.war /usr/local/tomcat/webapps/
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS -server -Xmx4736M -Xms4736M -Xmn1728M -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 8080
CMD ["/usr/local/tomcat/bin/catalina.sh","run"]
```
### 基础的部分就不说了，这里只指明需要注意的地方
1. 选取8.5.46-jdk8-openjdk-slim作为基镜像，减小镜像的大小  
2. 设置环境变量JAVA_OPTS，控制jvm的内存大小，不然jdk8默认情况下jvm会根据宿主机的内存分配自己的内存.据说jdk10以后会根据容器的大小分配内存    
3. CMD ["/usr/local/tomcat/bin/catalina.sh","run"]，直接运行tomcat的catalina.sh脚本，曾经尝试过在这里运行startup.sh，但是那个脚本执行完毕后会自动进入后台模式，而docker容器必须有前台运行的应用，否则容器会直接挂掉，所以采用这种方式。  
4. 采用COPY命令加入war包，因为tomcat运行时会自动解压，而Docker的ADD命令的效率低于COPY，所以使用COPY命令  
