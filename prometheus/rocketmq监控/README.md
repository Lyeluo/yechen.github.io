#### exporter启动命令
```bash
docker run -d -e NAMESRV_ADDR=192.168.2.237:9876 --log-opt max-size=200m --log-opt max-file=1 --name rocketmq-exporter -p 5557:5557 --restart=always 192.168.12.124:7080/exporter/rocketmq-exporter:1.0
```
    
