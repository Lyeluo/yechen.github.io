FROM openjdk:8-jre-slim
MAINTAINER liujy@yuanian.com
COPY app.jar /app.jar
ENV TZ=Asia/Shanghai \
    JAVA_OPT="-Xmx1024m -Xms1024m -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M -Dfile.encoding=utf-8"\
    JAVA_PARAM=""
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /
EXPOSE 8081
ENTRYPOINT ["sh","-c","java ${JAVA_OPT} -jar app.jar ${JAVA_PARAM}"]
