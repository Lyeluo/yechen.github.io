1. 运行环境 jdk8.0 + 
2. 下载地址 https://elasticsearch.cn/download/
## Elasticsearch 安装
### 容器版本


 1. 下载镜像 
```
docker pull elasticsearch:7.1.1
```
 2. 查看镜像
 `docker images` 
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592898365_51.png)
 3.创建自定义的网络
(用于连接到连接到同一网络的其他服务(例如Kibana))
`docker network create somenetwork`
 4. 运行 elasticsearch
```
docker run -d --name elasticsearch --net somenetwork -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.1.1
```
 5.  查看容器状态，`docker ps -a`
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592898536_87.png)
 6. 检测是否安装成功
`curl -X GET http://localhost:9200`

### 非容器版本
运行环境要求：jdk1.8+


 1. 下载Elasticsearch
下载地址https://elasticsearch.cn/download/ 。下载完安装包后，通过ftp或rz命令上传到服务器，然后解压。
 2. 修改系统配置
```
# 添加用户
sudo groupadd elsearch
sudo useradd elsearch -g elsearch -p 
# 更改elasticsearch文件夹及内部文件的所属用户及组为elsearch:elsearch
sudo chown -R elsearch:elsearch /elsearch
# 修改系统配置
sudo vim /etc/security/limits.conf
# 添加配置
elsearch soft nofile 65536
elsearch hard nofile 65536
elsearch soft memlock unlimited
elsearch hard memlock unlimited
sudo vim /etc/sysctl.conf
# 添加配置
vm.max_map_count = 262144
# 执行sudo sysctl -p
sudo vim /etc/security/limits.d/90-nproc.conf
# 添加配置
work          soft    nproc     65535
# 切换到root用户执行重启命令 shutdown -r now，使刚刚的配置生效
```
 3. 修改配置文件
 __config/elasticsearch.yml__ 
```
# 设置集群名称
cluster.name: yuanian-es
# 设置节点名称
node.name: node-1
# 允许所有地址访问
network.host: 0.0.0.0
# 端口
http.port: 9200
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
# 单机部署必须执行master节点
cluster.initial_master_nodes: ["node-1"]
# 开启跨域访问支持，默认为false
http.cors.enabled: true
# 跨域访问允许的域名地址，(允许所有域名)以上使用正则
http.cors.allow-origin: /.*/

```
 4. 启动
执行 `sudo ./bin/elasticsearch -d` 启动elasticsearch  
执行 `curl -X GET http://localhost:9200` ，若返回如下结果，则证明elasticsearch安装成功
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592893347_42.png)
4.修改elasticsearch配置文件
```yaml
node.name: node-1
#允许所有地址访问
network.host: 0.0.0.0

http.port: 9200
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
#单机部署必须执行master节点
cluster.initial_master_nodes: ["node-1"]
# 开启跨域访问支持，默认为false
http.cors.enabled: true
# 跨域访问允许的域名地址，(允许所有域名)以上使用正则
http.cors.allow-origin: /.*/
```
5.启动
./bin/elasticsearch -d
6.测试
curl -X GET http://localhost:9200

## Logstash 安装
### 容器版本


 1. 下载镜像、查看镜像
```
docker pull logstash:7.1.1
docker images
```
 2. 编写配置文件
在工作目录建立一个 docker 目录 并在里面创建了 logstash 目录，用来存放所有配置
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592899084_65.png)
在logstash目录中存放配置文件 default.conf
```
# 接收kafka上的日志消息
input{
    kafka {
        bootstrap_servers => ["192.168.2.237:9092"]
        group_id => "ecs2"
        auto_offset_reset => "earliest"
        consumer_threads => "5"
        #这里不设置为true得话，下面获取不到值%{[@metadata][kafka][topic]}
        decorate_events => "true"
        #接收的kafka队列名称
        topics => ["ms-job-console","log4j"]
        type => "ecs2"
   }
}
# 数据过滤
filter {
   if [type] == 'ecs2'{
     grok {
     #分词对应log4j2的分词pattern
        match => { "message" => "%{GREEDYDATA:date} %{GREEDYDATA:timer} %{LOGLEVEL:loglevel} %{GREEDYDATA:service}  %{GREEDYDATA:className} \[Class = %{GREEDYDATA:className1}\] \[File = %{GREEDYDATA:classFile}\] \[Line = %{NUMBER:classLine}\] \[Method = %{GREEDYDATA:classMethod}\] \[%{GREEDYDATA:logModule}\] %{GREEDYDATA:log-context}"}
     }
   }
}
# 输出配置为本机的9200端口，这是ElasticSerach服务的监听端口
output {
   if "ecs2" in [type]{
     elasticsearch {
       hosts => ["192.168.2.236:9200"]
       #%{[@metadata][kafka][topic]} 为kafka得topic名称
       #此处建议索引后天追加时间戳方便根据时间清除日志信息
       index=>"%{[@metadata][kafka][topic]}-%{+YYYY.MM.dd}"
     }
  }
}
```
 3. 启动容器
```
docker run -it -d -p 5044:5044 --name logstash --net somenetwork  -v {path}/:/usr/share/logstash/conf.d/ logstash:7.1.1
```
 4. 查看容器 `docker ps -a`
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592899372_70.png) 
安装成功

### 非容器版本
运行环境 jdk1.8+

 1. 下载logstash
下载地址https://elasticsearch.cn/download/ 。下载完安装包后，通过ftp或rz命令上传到服务器，然后解压。
 2. 添加配置文件         
解压压缩包后，在config目录下添加配置文件default.conf，在此以接收kafka消息为例配置文件
```
# 接收kafka上的日志消息
input{
    kafka {
        bootstrap_servers => ["192.168.2.237:9092"]
        group_id => "ecs2"
        auto_offset_reset => "earliest"
        consumer_threads => "5"
        #这里不设置为true得话，下面获取不到值%{[@metadata][kafka][topic]}
        decorate_events => "true"
        #接收的kafka队列名称
        topics => ["ms-job-console","log4j"]
        type => "ecs2"
   }
}
# 数据过滤
filter {
   if [type] == 'ecs2'{
     grok {
     #分词对应log4j2的分词pattern
        match => { "message" => "%{GREEDYDATA:date} %{GREEDYDATA:timer} %{LOGLEVEL:loglevel} %{GREEDYDATA:service}  %{GREEDYDATA:className} \[Class = %{GREEDYDATA:className1}\] \[File = %{GREEDYDATA:classFile}\] \[Line = %{NUMBER:classLine}\] \[Method = %{GREEDYDATA:classMethod}\] \[%{GREEDYDATA:logModule}\] %{GREEDYDATA:log-context}"}
     }
   }
}
# 输出配置为本机的9200端口，这是ElasticSerach服务的监听端口
output {
   if "ecs2" in [type]{
     elasticsearch {
       hosts => ["192.168.2.236:9200"]
       #%{[@metadata][kafka][topic]} 为kafka得topic名称
       #此处建议索引后天追加时间戳方便根据时间清除日志信息
       index=>"%{[@metadata][kafka][topic]}-%{+YYYY.MM.dd}"
     }
  }
}
```
 3. 启动        
执行 `sudo nohup ./bin/logstash -f ./config/default.conf --config.reload.automatic &` 启动logstash

 
## Kibana 安装
### 容器版本


 1. 下载镜像 查看镜像
```
docker pull kibana:7.1.1
docker images
``` 
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592899754_77.png)
注意:在本例中，Kibana使用默认配置，并希望连接到正在运行的Elasticsearch实例http://localhost:9200
 2. 运行 Kibana
```
docker run -d --name kibana --net somenetwork -p 5601:5601 kibana:7.1.1
```
 3. 查看容器启动状态,`docker ps -a`
![图片描述](/tfl/captures/2020-06/tapd_61177290_base64_1592899865_58.png)


### 非容器版本

 1. 下载kibana
下载地址https://elasticsearch.cn/download/ 。下载完安装包后，通过ftp或rz命令上传到服务器，然后解压
 2. 修改系统配置      
Kibana同样不能用root用户启动，所以需要先授权，`sudo chown-R  elsearch:elsearch  kibana/`
 3. 修改kibana配置文件
 __config/kibana.yml__ 
```
# 配置端口
server.port:5601
# kibana服务器地址
server.host:192.168.2.236
# elasticsearch服务器地址
elasticsearch.url: "http://192.168.2.236:9200" 
# 设置多语言
i18n.locale: "zh-CN"
```
 4. 启动kibana   
启动kibana，执行命令`sudo  ./bin/kibana`。
默认访问地址 http://192.168.2.236:5601/ 

 

