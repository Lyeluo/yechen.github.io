#!/bin/bash
# Author     :liujy@yuanian.com
# Date       : 2019年12月19日
#URL为判断服务是否启动的rest接口，要根据不同服务修改接口

DEBUG=IS_DEBUG
NAMESPACE=namespace
IMAGE_NAME=imagename
DUMP_PATH = -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/$NAMESPACE/$IMAGE_NAME/java_heapdump.hprof

cd /opt/$NAMESPACE/$IMAGE_NAME/
if [ $DEBUG = 'true' ];then
  nohup  java -Xdebug -Xrunjdwp:transport=dt_socket,suspend=n,server=y,address=18202 -Xmx1024m -Xms512m ${DUMP_PATH} -Dfile.encoding=utf-8 -jar app.jar &
else
  nohup  java -Xmx1024m -Xms1024m -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M ${DUMP_PATH} -Dfile.encoding=utf-8 -jar app.jar &
fi

tail -f /dev/null

