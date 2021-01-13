### 1.首先进入容器中
```bash
docker exec -it pmm-server /bin/bash
```
### 2.修改grafana.ini，允许匿名登录
 ```bash
 vim /etc/grafana/grafana.ini 
```
然后修改配置文件
```bash
[auth.anonymous]
# enable anonymous access
enabled = true
# 允许iframe嵌套
allow_embedding = true
# 修改默认主题
default_theme = light
```
### 3.修改nginx配置文件
```bash
vim /etc/nginx/conf.d/pmm-ssl.conf
```
注释以下内容
```bash
#add_header X-Content-Type-Options nosniff;
#add_header X-XSS-Protection "1; mode=block";
#add_header X-Frame-Options DENY;
```
然后添加以下配置
```bash
proxy_hide_header X-Frame-Options;
add_header X-Frame-Options ALLOWALL;
```
重新加载nginx配置文件
```bash
nginx -s reload
```
