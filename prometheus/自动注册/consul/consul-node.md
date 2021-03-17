部署consul
```bash
docker run -d --name consul --restart=always -p 8500:8500 consul:1.8.7
```
上线服务
```bash
curl --request PUT --data @consul-node.json http://192.168.2.184:8500/v1/agent/service/register?replace-existing-checks=1
```
json文件
```json
{
  "ID": "node-exporter-192.168.48.85",
  "Name": "node-exporter-192.168.48.85",
  "Tags": [
    "node-exporter"
  ],
  "Address": "192.168.48.85",
  "Port": 9100,
  "Meta": {},
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.48.85:9100/metrics",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
```
consul的请求官方说明文档地址 https://www.consul.io/docs/discovery/services

下线服务
```bash
curl -X PUT http://192.168.2.184:8500/v1/agent/service/deregister/node-exporter 
```
- 注意：node-exporter为id，需要每个服务不一样

prometheus.yml配置
```yml
    - job_name: 'consul-node-exporter'
      consul_sd_configs:
      - server: '192.168.2.184:8500'
        services: []
      relabel_configs:ho
      - source_labels: [__meta_consul_tags]
        regex: .*node-exporter.*
        action: keep
      - source_labels: [ __meta__consul_service ]
        target_label: instance

```
部署一个consul-server，同时启动consul配置中心的持久化
```bash
docker run -d --name consul --restart=always -v  `pwd`/consul/data:/consul/data \
 -v  `pwd`/consul/config:/consul/config -p 8500:8500 consul agent -server -ui -client=0.0.0.0 -bootstrap-expect=1
```
