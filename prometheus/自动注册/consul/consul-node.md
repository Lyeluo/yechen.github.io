consul请求地址

上线服务
```bash
curl --request PUT --data @consul-node.json http://192.168.2.184:8500/v1/agent/service/register?replace-existing-checks=1
```
json文件
```json
{
  "ID": "java-exporter-publish",
  "Name": "java-exporter-publish",
  "Tags": [
    "java-exporter"
  ],
  "Address": "192.168.12.187",
  "Port": 3010,
  "Meta": {},
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.12.187:3010/metrics",
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
      relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*node-exporter.*
        action: keep
      - source_labels: [ __meta__consul_service ]
        target_label: instance

```
