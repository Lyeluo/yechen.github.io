### 1.下载java-agent
下载地址：https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.14.0/jmx_prometheus_javaagent-0.14.0.jar
### 2.编写java-agent配置文件
配置文件simple-config.yml，此内容对应grafana的dashboard，来源 https://grafana.com/grafana/dashboards/8563
```yml 
lowercaseOutputLabelNames: true
lowercaseOutputName: true
whitelistObjectNames: ["java.lang:type=OperatingSystem"]
blacklistObjectNames: []
rules:
  - pattern: 'java.lang<type=OperatingSystem><>(committed_virtual_memory|free_physical_memory|free_swap_space|total_physical_memory|total_swap_space)_size:'
    name: os_$1_bytes
    type: GAUGE
    attrNameSnakeCase: true
  - pattern: 'java.lang<type=OperatingSystem><>((?!process_cpu_time)\w+):'
    name: os_$1
    type: GAUGE
    attrNameSnakeCase: true
```
### 3.启动java程序
```bash
nohup java -javaagent:/opt/java-server/publish/jmx_prometheus_javaagent-0.14.0.jar=3010:/opt/java-server/publish/simple-config.yml -jar app.jar &
```
此命令指定了代理的java-agent与配置文件，同时指定端口为3010
### 4.配置prometheus
修改配置文件prometheus.yml
```yaml
scrape_configs:
  - job_name: 'java'
    static_configs:
    - targets: ['<host>:<port>']
```
重启
```bash
systemctl restart prometheus
```
### 5.在grafana配置面板
dashboard文件下载地址 https://grafana.com/grafana/dashboards/8563
