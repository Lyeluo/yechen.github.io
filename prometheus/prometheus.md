## prometheus安装
https://www.jianshu.com/p/967cb76cd5ca
## prometheus+grafana配置流程
### 首先，安装对应的exporter
查看prometheus支持的所有exporters
```sh
https://prometheus.io/docs/instrumenting/exporters/
```
github查看安装包下载地址，只需要在项目地址后追加/releases。如
```
https://github.com/oliver006/redis_exporter/releases
```
exporter不一定必须安装在被监控组件的服务器，下载完安装包后解压即可使用
### 然后，修改prometheus配置
修改prometheus配置文件`prometheus.yml`，添加`job_name`,如下
```yml
- job_name: redis_exporter
  static_configs:
  - targets: ['10.5.86.84:9121']
```
修改完配置后重启prometheus，调用rest请求即可
```bash
curl -XPOST  http://127.0.0.1:9090/prometheus/-/reload
```
### 最后，配置grafana
登录grafana的dashboards平台，查询所需的json文件，地址
```bash
https://grafana.com/grafana/dashboards
```
下载对应的json文件到本地，然后导入grafana  
最后创建对应的视图，存储选择prometheus即可  
