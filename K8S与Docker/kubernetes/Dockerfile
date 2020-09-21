FROM openjdk:8-jre-slim
MAINTAINER ecs@yuanian.com
LABEL description="ecs-micro"
COPY restart.sh /restart.sh
COPY kubectl /usr/bin/
COPY rancher /usr/bin/
ENV TZ=Asia/Shanghai \
    JAVA_OPT="-Xmx2048m -Xms2048m -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M  -Dfile.encoding=utf-8" \
    JAR_PATH=/opt/
RUN ln -snf /usr/share/zoneinfo/$TZ  /etc/localtime && echo $TZ > /etc/timezone \
     && sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list && apt-get clean \
     && apt-get -y update && apt-get -y install libfreetype6 && apt-get -y install fontconfig \
     && chmod +x /usr/bin/kubectl && chmod +x /usr/bin/rancher
CMD ["bash","/restart.sh"]
