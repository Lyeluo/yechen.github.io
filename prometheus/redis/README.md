#### 镜像部署
1.启动命令 
```bash
docker run -d -e REDIS_ADDR=192.168.2.172:6379 --name redis_exporter -p 9121:9121 --restart=always oliver006/redis_exporter:v1.13.1-alpine
```
2.环境变量  
|    Name     | Description|
| :---------- | :--- |
| REDIS_ADDR | redis的地址节点 |  
| REDIS_PASSWORD | redis的密码 |  
| REDIS_ALIAS | redis节点的别名 |  
| REDIS_FILE | 包含Redis节点的文件路径 |  
#### grafana面板

上线服务
```bash
curl --request PUT --data @consul-node.json http://192.168.2.184:8500/v1/agent/service/register?replace-existing-checks=1
```
json文件
```json
{
  "ID": "redis-192.168.48.85",
  "Name": "redis-192.168.48.85",
  "Tags": [
    "redis"
  ],
  "Address": "192.168.2.185",
  "Port": 9121,
  "Meta": {
    "instanceName": "172服务器的redis"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.2.185:9121/metrics",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
```
