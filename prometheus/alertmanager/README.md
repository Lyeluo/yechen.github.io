## 启动命令
```bash
./alertmanager -config.file=/opt/alertmanager/alertmanager-0.21.0.linux-amd64/alertmanager.yml --storage.path=/opt/alertmanager/data
```
- --config.file用于指定alertmanager配置文件路径
- --storage.path用于指定数据存储路径
## 热加载
```bash
curl -X POST http://localhost:9093/-/reload
```

## 邮件告警
```
global:
  smtp_smarthost: 'smtp.163.com:25'   #163服务器
  smtp_from: '000@163.com' 　#发邮件的邮箱
  smtp_auth_username: '000@163.com' #发邮件的邮箱用户名，也就是你的邮箱
  smtp_auth_password: '000'	 #邮箱的授权密码 (如果是163邮箱，需要在设置->常规设置->点击左侧的客户端授权密码->开启授权密码)
templates:
- '/etc/alertmanager/template/*.tmpl' #加载所有消息通知模板

route:
  receiver: 'default-receiver'
  group_by: ['alertname','cluster']	 #将传入警报分组在一起的标签。例如，cluster=A和alertname=LatencyHigh的多个警报将批处理为单个组。
  group_wait：30s  #当传入的警报创建新的警报组时，至少等待"30s"发送初始通知。
  group_interval：5m  #当发送第一个通知时，等待"5m"发送一批新的警报，这些警报开始针对该组触发。 （如果是group_by里的内容为新的如：alertname=1,alertname=2 会马上发送2封邮件, 如果是group_by之外的会等待5m触发一次）
  repeat_interval: 4h #如果警报已成功发送，请等待"4h"重新发送，重复发送邮件的时间间隔
  routes: #所有与下列子路由不匹配的警报将保留在根节点，并被分派到'default-receiver'。
  - receiver: 'database-pager'
    group_wait: 10s
    match_re:
      service: mysql|cassandra	#带有service=mysql或service=cassandra的所有警报都被发送到'database-pager'
  - receiver: 'frontend-pager'
    group_by: [product, environment]
    match:
      team: frontend #team=frontend的 和
receivers:
- name: default-receiver #不同的报警 发送给不同的邮箱
  email_configs:
  - to: '475132489@qq.com,44646@qq.com'  #收邮件的邮箱 多个邮箱用,隔开
	html: '{{ template "default.html" . }}'   #应用哪个模板
    headers: { Subject: "[WARN] 报警邮件default" }   #邮件头信息
- name: database-pager
  email_configs:
  - to: '2312123@qq.com'
	html: '{{ template "database.html" . }}'     #应用哪个模板
    headers: { Subject: "[INFO] 报警邮件test" }   #邮件头信息
```
## 企信告警markdown模板

## 【告警】
- 名称：
- 级别：
- 信息：
- 详情：
- 告警值：
- 实例：
- 实例类型：
- 故障时间：
