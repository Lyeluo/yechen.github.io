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
