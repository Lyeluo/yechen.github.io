https://blog.csdn.net/zhizhengguan/article/details/87916519

7.2、
[auth.anonymous]

prometheus执行文件位置
/usr/sbin/prometheus
prometheus配置文件位置
/etc/prometheus.yml
修改pmm 对iframe的限制
/etc/nginx/conf.d

# Default UI theme ("dark" or "light")
;default_theme = dark


pmm2 安装
docker启动
```bash
docker run --detach --restart always \
--publish 80:80 --publish 443:443 \
--volumes-from pmm-data -v /opt/pmm-server/prometheus/prometheus.yml:/etc/prometheus.yml --name pmm-server \
percona/pmm-server:2
```
修改配置文件后热加载prometheus
```bash
docker exec -it pmm-server curl -X POST http://localhost:9090/prometheus/-/reload
```

```bash
# 注册到pmm-server
pmm-admin config --force --server-url=http://admin:admin@192.168.12.145
# 添加监控模块
pmm-admin add mysql --query-source=perfschema --username=root --password=root ps-mysql
# 添加慢查询
pmm-admin add mysql --query-source=slowlog --username=root --password=root sl-mysql
```
