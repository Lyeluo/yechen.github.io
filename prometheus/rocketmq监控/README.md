#### exporter启动命令
```bash
docker run -d -e NAMESRV_ADDR=192.168.2.237:9876 --name rocketmq-exporter -p 5557:5557 --restart=always rocketmq-exporter:1.0
```
