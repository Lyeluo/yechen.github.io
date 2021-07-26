```
docker run -d  -p 9308:9308 --name kafka-exporter --restart=always danielqsj/kafka-exporter --kafka.server=192.168.2.237:9092
```
对接带有acl的kafka
```bash
docker run --rm danielqsj/kafka-exporter:latest --kafka.server=192.168.2.184:9092 --sasl.enabled=true --sasl.username=admin --sasl.password=admin
```
