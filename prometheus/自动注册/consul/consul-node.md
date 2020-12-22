consul请求地址

上线服务
```bash
curl --request PUT --data @consul-node.json http://192.168.2.184:8500/v1/agent/service/register?replace-existing-checks=1
```
json文件
```json
{
  "ID": "node-exporter",
  "Name": "node-exporter-192.168.2.237",
  "Tags": [
    "node-exporter"
  ],
  "Address": "192.168.2.237",
  "Port": 9100,
  "Meta": {
    "app": "spring-boot",
    "team": "appgroup",
    "project": "bigdata"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.2.184:9100/metrics",
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
