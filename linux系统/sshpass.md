```bash
#直接远程连接某主机
sshpass -p {密码} ssh {用户名}@{主机IP}

#远程连接指定ssh的端口
sshpass -p {密码} ssh -p ${端口} {用户名}@{主机IP} 

#从密码文件读取文件内容作为密码去远程连接主机
sshpass -f ${密码文本文件} ssh {用户名}@{主机IP} 

#从远程主机上拉取文件到本地
sshpass -p {密码} scp {用户名}@{主机IP}:${远程主机目录} ${本地主机目录}

#将主机目录文件拷贝至远程主机目录
sshpass -p {密码} scp ${本地主机目录} {用户名}@{主机IP}:${远程主机目录} 

#远程连接主机并执行命令
sshpass -p {密码} ssh -o StrictHostKeyChecking=no {用户名}@{主机IP} 'rm -rf /tmp/test'

-o StrictHostKeyChecking=no ：忽略密码提示

```
