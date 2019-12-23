## kafka
```
1.查看版本
find ./ -name \*kafka_\* | head -1 | grep -o '\kafka[^\n]*'
2.重启
nohup ./bin/kafka-server-start.sh config/server.properties >  /dev/null 2>&1 &
```
## 启动windows环境的filebeat
```
./filebeat -c filebeat.yml -e

2.filebeat.yml文件
filebeat.input:
- type: log
  enable: true
  paths:
    - D:\project\micro-v2.0\target\rolling\*.log
  tags: ["ecs2-console"]  
filebeat.config.modules:
  # Glob pattern for configuration loading
  path: ${path.config}/modules.d/*.yml
  # Set to true to enable config reloading
  reload.enabled: false
setup.template.settings:
  index.number_of_shards: 3  
output.kafka:
  enabled: true
  hosts: ["192.168.2.183:9092","192.168.2.184:9092","192.168.2.185:9092"]
  topic: filebeat
  version: 0.10.2.1
```
## logstash
```
1.重启logstash
cd /elk/logstash-6.2.3/bin
nohup ./logstash -f ./default.conf --config.reload.automatic &
2.查看日志
tail -f logs/logstash-plain.log
```

## elasticsearch
```
1.后台启动elasticsearch-head 
nohup grunt server &
2.启动elasticsearch
切换用户到elasticsearch
进入到elasticsearch安装目录下
执行命令bin/elasticsearch -d
3.查看elasticsearch日志
tail -f /opt/servers/work/elasticsearch-6.2.3/logs/elasticsearch.log
4.清理es的索引下面的文档
curl -XDELETE 'http://192.168.2.186:9200/索引名称（可用通配符）'
```

## kubernetes命令
```
1.查看pod历史日志
kubectl logs podName --previous

```
