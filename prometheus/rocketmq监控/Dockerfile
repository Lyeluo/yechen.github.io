FROM openjdk:8-jre-slim
MAINTAINER micro-liujy
ADD rocketmq-exporter-0.0.1-SNAPSHOT.jar quickstart.jar
ENV TZ=Asia/Shanghai \
    ROCKETMQ_VERSION=4_2_0 \
    NAMESRV_ADDR=127.0.0.1:9876 \
    ENABLECOLLECT=true
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 5557
ENTRYPOINT ["java","-jar","quickstart.jar"]
