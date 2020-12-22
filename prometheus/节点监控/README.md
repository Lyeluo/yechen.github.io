```bash
https://www.cnblogs.com/mcsiberiawolf/articles/10248778.html
```
下载
```bash
curl -u duyj:welcome1 -O http://192.168.48.96:8081/artifactory/ecs2_java_prod/common/prometheus/exporter/node_exporter-1.0.1.linux-amd64.tar.gz
```
解压
```bash
tar zxvf node_exporter-1.0.1.linux-amd64.tar.gz 
```
```
vim /etc/systemd/system/node_exporter.service
```

[Unit]
Description=node_exporter
Documentation=https://prometheus.io/
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/exporter/node_exporter-1.0.1.linux-amd64/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target

```bash
systemctl daemon-reload
systemctl start node_exporter.service
#查看状态
systemctl status node_exporter.service
#开机启动
systemctl enable node_exporter.service
```
正常状态
```
● node_exporter.service - node_exporter
   Loaded: loaded (/etc/systemd/system/node_exporter.service; disabled; vendor preset: disabled)
   Active: active (running) since 三 2020-12-16 11:17:30 CST; 9s ago
     Docs: https://prometheus.io/
 Main PID: 30535 (node_exporter)
   Memory: 8.3M
   CGroup: /system.slice/node_exporter.service
           └─30535 /opt/exporter/node_exporter-1.0.1.linux-amd64/node_exporter

12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:112 collector=thermal_zone
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:112 collector=time
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:112 collector=timex
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:112 collector=udp_queues
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:112 collector=uname
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:112 collector=vmstat
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:112 collector=xfs
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:112 collector=zfs
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=node_exporter.go:191 msg="Listening on" address=:9100
12月 16 11:17:30 vm-machinename node_exporter[30535]: level=info ts=2020-12-16T03:17:30.808Z caller=tls_config.go:170 msg="TLS is disabled and it cannot be enabled on the fly." http2=false

```
