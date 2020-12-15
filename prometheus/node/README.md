```bash
https://www.cnblogs.com/mcsiberiawolf/articles/10248778.html
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
ExecStart=/usr/local/node_exporter/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target

```bash
systemctl daemon-reload
systemctl start node_exporter.service
systemctl enable node_exporter.service
```
