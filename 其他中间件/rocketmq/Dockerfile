FROM openjdk:8-jre-slim
MAINTAINER ecs-micro
LABEL description="ecs-micro"
COPY rocketmq-console-ng-1.0.1.jar /
ENV TZ=Asia/Shanghai \
    NAMESRV_ADDR=127.0.0.1:9876
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 8081
CMD java -jar rocketmq-console-ng-1.0.1.jar --rocketmq.config.namesrvAddr=$NAMESRV_ADDR
