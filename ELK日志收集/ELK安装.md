1. 运行环境 jdk8.0 + 
2. 下载地址 https://elasticsearch.cn/download/
3.系统配置
```bash
#添加用户
groupadd elsearch
useradd elsearch -g elsearch -p 
更改elasticsearch文件夹及内部文件的所属用户及组为elsearch:elsearch
chown -R elsearch:elsearch /elsearch

#修改系统配置
vim /etc/security/limits.conf
#添加配置
elsearch soft nofile 65536
elsearch hard nofile 65536
elsearch soft memlock unlimited
elsearch hard memlock unlimited
vim /etc/sysctl.conf
#添加配置
vm.max_map_count = 262144
执行sysctl -p
vim /etc/security/limits.d/90-nproc.conf
#添加配置
work          soft    nproc     65535

#切换到root用户执行重启命令 `shutdown -r now`
```
4.修改elasticsearch配置文件
```yaml
node.name: node-1
#允许所有地址访问
network.host: 0.0.0.0

http.port: 9200
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
#单机部署必须执行master节点
cluster.initial_master_nodes: ["node-1"]
# 开启跨域访问支持，默认为false
http.cors.enabled: true
# 跨域访问允许的域名地址，(允许所有域名)以上使用正则
http.cors.allow-origin: /.*/
```
5.启动
./bin/elasticsearch -d
6.测试
curl -X GET http://localhost:9200

# kibana
1.授权
chown -R  elsearch:elsearch  kibana/
2.修改文件
vmi config/kibana.yml

配置内容：
```bash
#配置端口
server.port:5601
#kibana服务器地址
server.host:192.168.102.139 
#elasticsearch服务器地址
elasticsearch.url: "http://192.168.2.236:9200" 
#设置多语言
i18n.locale: "zh-CN"
```
启动kibana

 ./bin/kibana

后台启动方式 

nohup ./bin/kibana &

