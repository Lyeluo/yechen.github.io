FROM alpine:3.12.0
MAINTAINER micro-liujy
ADD filebeat.tar.gz /usr/share/filebeat
ENV TZ=Asia/Shanghai \
    elasticsearch_host=127.0.0.1:9200
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /usr/share/filebeat
EXPOSE
CMD ["sh","./filebeat"]
