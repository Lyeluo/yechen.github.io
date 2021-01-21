## 安装环境
192.168.12.186

## 下载安装包
想要安装docker-compose，可以自行访问github地址下载https://github.com/docker/compose/releases
## 安装
将安装包上传到linux服务器中，然后copy到指定目录
```
cp docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
```
授权
```
chmod +x /usr/local/bin/docker-compose
```
安装完毕后查看是否安装成功
```
[root@vm-machinename bin]# docker-compose version
docker-compose version 1.25.2-rc2, build be4b7b55
docker-py version: 4.1.0
CPython version: 3.7.5
OpenSSL version: OpenSSL 1.1.0l  10 Sep 2019
```

## 备注
1.执行完`docker-compose up`后 会自动根据当前目录创建一个network，所以想要更改目录前需要先执行`docker-compose down`然后再调整目录
2.启动时可以通过添加 -p 参数指定项目名称，docker-compose默认会利用项目名称作为网络名称，如 `docker-compose -p ecs up -d`
