```bash
docker run -d -p 9114:9114 --restart=always --name=elasticsearch-exporter justwatch/elasticsearch_exporter:1.1.0 --es.uri=http://192.168.2.236:9200
```
