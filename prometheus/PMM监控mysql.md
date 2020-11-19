https://blog.csdn.net/zhizhengguan/article/details/87916519

7.2、修改grafana.ini，禁止匿名登录[root@c74f5be8ed88 opt]# vi /etc/grafana/grafana.ini 
[auth.anonymous]
# enable anonymous access
# 控制是否需要登录
#enabled = True
prometheus执行文件位置
/usr/sbin/prometheus
prometheus配置文件位置
/etc/prometheus.yml
