运行环境 jdk1.8+，文档安装的rocket版本为4.7.0


 1. 安装jdk （参照jdk安装章节）  
执行命令`java -version`，验证是否安装成功  
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592884682_22.png)
 2. 下载源码打包
执行`mvn clean package -Dmaven.test.skip=true` 打包源码。
也可以直接下载打包后的文件，下载地址为：https://rocketmq.apache.org/dowloading/releases/ 。  
我这里是自己打包的所以执行命令在distribution/target/rocketmq-4.7.0/rocketmq-4.7.0下，直接下载安装包直接进到bin的上级目录即可。
 3. 修改nameserver配置
进入目录 distribution/target/rocketmq-4.7.0/rocketmq-4.7.0 下，修改文件 __conf/broker.conf__ ，添加配置brokerIP1 =192.168.2.237，192.168.2.237为本机地址。
 4. 启动nameserver服务
执行 ` sudo nohup sh bin/mqnamesrv &gt;./log/mqnamesrv.log 2&gt;&1 & `   ,启动rocket-nameserver。
 5. 启动broker服务
`sudo nohup sh bin/mqbroker -n 192.168.2.237:9876 -c conf/broker.conf &gt;./log/broker.log 2&gt;&`  
启动rocket-broker。注意：将192.168.2.237换为自己的服务器地址。  
 __broker.conf的配置内容如下：__ 
```
brokerClusterName = DefaultCluster
brokerName = broker-a
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
# 增加此列，否则非本机无法注册rocketmq
brokerIP1 = 192.168.2.185
```
 6. 列表项
执行：`sudo export NAMESRV_ADDR=localhost:9876`添加临时环境变量。
执行：`sudo sh bin/tools.sh org.apache.rocketmq.example.quickstart.Producer` 发送消息
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592892119_42.png)
执行：`sudo sh bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer`接收消息
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592892148_26.png)
出现类似以上截图内容，则证明rocket-nameserv与rocket-broker安装成功
 7. 启动rocket-console 控制台服务
```
sudo nohup java -jar rocketmq-console-ng-1.0.1.jar -rocketmq.config.namesrvAddr=192.168.2.237:9876 & 
```
	默认访问地址为http://192.168.2.237:8080
