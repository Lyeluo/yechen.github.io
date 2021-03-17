FROM openjdk:8-jre-slim
MAINTAINER micro-liujy
COPY monitor-client.jar /opt/monitor-client.jar
COPY consul-template /opt/consul-template
COPY runConsulTemplate.sh /opt/runConsulTemplate.sh
ENV TZ=Asia/Shanghai \
    CONSUL_CONFIG_KEY="" \
    CONSUL_ADDR="" \
    CONSUL_PORT="" \
    MONITOR_CLIENT_ID=""
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 9011
ENTRYPOINT ["cd /opt;java","-jar","monitor-client.jar"]
