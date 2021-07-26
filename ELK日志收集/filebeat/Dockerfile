FROM centos:centos7
MAINTAINER micro-liujy
ADD filebeat.tar.gz /usr/share/filebeat
ENV TZ=Asia/Shanghai \
    elasticsearch_host=127.0.0.1:9200
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /usr/share/filebeat
CMD ["sh","./filebeat"]
