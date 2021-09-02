灰度发布是指在黑与白之间，能够平滑过渡的一种发布方式。AB test就是一种灰度发布方式，让一部分用户继续用A，一部分用户开始用B，如果用户对B没有什么反对意见，那么逐步扩大范围，把所有用户都迁移到B上面来。

灰度发布可以保证整体系统的稳定，在初始灰度的时候就可以发现、调整问题，以保证其影响度。

灰度发布常见一般有三种方式:

```
Nginx+LUA方式

根据Cookie实现灰度发布

根据来路IP实现灰度发布
```

本文主要将讲解根据Cookie和来路IP这两种方式实现简单的灰度发布

# Nginx根据Cookie实现灰度发布

根据Cookie查询Cookie键为version的值，如果该Cookie值为V1则转发到hilinux_01，为V2则转发到hilinux_02。Cookie值都不匹配的情况下默认走hilinux_01所对应的服务器。

两台服务器分别定义为:

hilinux_01 192.168.1.100:8080
hilinux_02 192.168.1.200:8080

用if指令实现

```
upstream hilinux_01 {
    server 192.168.1.100:8080 max_fails=1 fail_timeout=60;
}

upstream hilinux_02 {
    server 192.168.1.200:8080 max_fails=1 fail_timeout=60;
}

upstream default {
    server 192.168.1.100:8080 max_fails=1 fail_timeout=60;
}

server {
  listen 80;
  server_name  www.hi-linux.com;
  access_log  logs/www.hi-linux.com.log  main;

  #match cookie
  set $group "default";
    if ($http_cookie ~* "version=V1"){
        set $group hilinux_01;
    }

    if ($http_cookie ~* "version=V2"){
        set $group hilinux_02;
    }

  location / {                       
    proxy_pass http://$group;
    proxy_set_header   Host             $host;
    proxy_set_header   X-Real-IP        $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    index  index.html index.htm;
  }
 }
```

# 用map指令实现

在Nginx里面配置一个映射，`$COOKIE_version`可以解析出Cookie里面的version字段。`$group`是一个变量，{}里面是映射规则。

如果一个version为V1的用户来访问，`$group`就等于hilinux_01。在server里面使用就会代理到http://hilinux_01上。version为V2的用户来访问，`$group`就等于hilinux_02。在server里面使用就会代理到http://hilinux_02上。Cookie值都不匹配的情况下默认走hilinux_01所对应的服务器。

```
upstream hilinux_01 {
    server 192.168.1.100:8080 max_fails=1 fail_timeout=60;
}

upstream hilinux_02 {
    server 192.168.1.200:8080 max_fails=1 fail_timeout=60;
}

upstream default {
    server 192.168.1.100:8080 max_fails=1 fail_timeout=60;
}
# 如果想要将cookie中的参数换成header，则改成 $http_version。version就是header 
map $COOKIE_version $group {
~*V1$ hilinux_01;
~*V2$ hilinux_02;
default default;
}

server {
  listen 80;
  server_name  www.hi-linux.com;
  access_log  logs/www.hi-linux.com.log  main;

  location / {                       
    proxy_pass http://$group;
    proxy_set_header   Host             $host;
    proxy_set_header   X-Real-IP        $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    index  index.html index.htm;
  }
 }
```

# Nginx根据来路IP实现灰度发布

如果是内部IP，则反向代理到hilinux_02(预发布环境)；如果不是则反向代理到hilinux_01(生产环境)。

```
upstream hilinux_01 {
    server 192.168.1.100:8080 max_fails=1 fail_timeout=60;
}

upstream hilinux_02 {
    server 192.168.1.200:8080 max_fails=1 fail_timeout=60;
}

upstream default {
    server 192.168.1.100:8080 max_fails=1 fail_timeout=60;
}

server {
  listen 80;
  server_name  www.hi-linux.com;
  access_log  logs/www.hi-linux.com.log  main;

  set $group default;
  if ($remote_addr ~ "211.118.119.11") {
      set $group hilinux_02;
  }

location / {                       
    proxy_pass http://$group;
    proxy_set_header   Host             $host;
    proxy_set_header   X-Real-IP        $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    index  index.html index.htm;
  }
}
```

## 如果你只有单台服务器，可以根据不同的IP设置不同的网站根目录来达到相同的目的。

```
server {
  listen 80;
  server_name  www.hi-linux.com;
  access_log  logs/www.hi-linux.com.log  main;

  set $rootdir "/var/www/html";
    if ($remote_addr ~ "211.118.119.11") {
       set $rootdir "/var/www/test";
    }

    location / {
      root $rootdir;
    }
}
```
