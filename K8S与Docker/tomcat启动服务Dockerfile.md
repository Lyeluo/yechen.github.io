## Tomcat服务启动Dockerfile-压缩版
```
FROM tomcat:8.5.46-jdk8-openjdk-slim
ADD ecs-console.war /usr/local/tomcat/webapps/
WORKDIR /usr/local/tomcat/conf/
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS -server -Xmx4736M -Xms4736M -Xmn1728M -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 8080
CMD ["/usr/local/tomcat/bin/catalina.sh","run"]
```
