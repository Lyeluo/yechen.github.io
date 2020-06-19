1. 
yum -y install java-1.8.0-openjdk

2. 
nohup sh bin/mqnamesrv >./log/mqnamesrv.log 2>&1 & 
3.
修改配置文件broker.conf中的brokerIP1地址为192.168.2.237
nohup sh bin/mqbroker -n 192.168.2.237:9876 -c conf/broker.conf >./log/broker.log 2>&1 &
4.
nohup java -jar rocketmq-console-ng-1.0.1.jar --rocketmq.config.namesrvAddr=192.168.2.237:9876 &
