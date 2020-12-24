## pushgetway
### 容器版本启动命令
```bash
docker run -d -p 9091:9091 --name=push-gateway --restart=always prom/pushgateway
```
默认 PushGateway 不做数据持久化操作，当 PushGateway 重启或者异常挂掉，导致数据的丢失，
我们可以通过启动时添加  -persistence.file 和 -persistence.interval  参数来持久化数据。
-persistence.file 表示本地持久化的文件，将 Push 的指标数据持久化保存到指定文件，
-persistence.interval 表示本地持久化的指标数据保留时间，若设置为 5m，则表示 5 分钟后将删除存储的指标数据。  
```bash
docker run -d -p 9091:9091 --name=push-gateway --restart=always prom/pushgateway "-persistence.file=pg_file –persistence.interval=5m"
```
### 时间设置
```
 Prometheus 每次从 PushGateway 拉取的数据，并不是拉取周期内用户推送上来的所有数据，而是最后一次 Push 到 PushGateway 上的数据，
 所以推荐设置推送时间小于或等于 Prometheus 拉取的时间，这样保证每次拉取的数据是最新 Push 上来的。
```
### API操作
删除某个job下的某个示例的所有指标
```bash
curl -X DELETE http://172.30.12.167:9091/metrics/job/job名称/instance/instance名称
```
删除某个job下所有的指标
```bash
curl -X DELETE http://172.30.12.167:9091/metrics/job/job名称
```
### Client SDK Push 数据到 Pushgateway
官方提供了  python、java、go 等不同语言类型 client
java的maven依赖
```xml
<dependency>
    <groupId>io.prometheus</groupId>
    <artifactId>simpleclient_pushgateway</artifactId>
    <version>0.7.0</version>
</dependency>
```
github地址: https://github.com/prometheus/client_java/blob/master/simpleclient/src/main/java/io/prometheus/client/Counter.java
