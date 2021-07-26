## docker部署mysql集群（主从同步）
参考文档地址：https://www.jianshu.com/p/ab20e835a73f


使用复制用户请求服务器公钥：
mysql -u repl -p123 -h 118.31.127.96 -P3307 --get-server-public-key
在这种情况下，服务器将RSA公钥发送给客户端，后者使用它来加密密码并将结果返回给服务器。插件使用服务器端的RSA私钥解密密码，并根据密码是否正确来接受或拒绝连接。

重新在从库配置change masrer to并且start slave，复制可以正常启动：

#停止主从复制
#清空之前的主从复制配置信息
stop slave;
reset slave;

#从新配置主从复制
change master to master_user='repl',master_password='123',master_host='118.31.127.96',master_port=3307,master_auto_position=1;
start slave;
