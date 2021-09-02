FROM openjdk:8-jre-slim
COPY jmx_prometheus_javaagent-0.14.0.jar /opt/jmx_prometheus_javaagent.jar
COPY simple-config.yml /opt/simple-config.yml
ENV TZ=Asia/Shanghai\
    JMX_PROMETHEUS_OPT=" -javaagent:/opt/jmx_prometheus_javaagent.jar=3010:/opt/simple-config.yml "
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone \
     && sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list && apt-get clean \
     && apt-get -y update && apt-get -y install libfreetype6 && apt-get -y install fontconfig
