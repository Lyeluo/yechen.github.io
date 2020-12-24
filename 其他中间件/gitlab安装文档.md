### 1.清华镜像源下载地址
https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/
### 2.前置文件安装
```bash
sudo yum install -y curl policycoreutils-python openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewalld
```
邮件系统
```bash
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
```
### 2.上传到服务器并执行安装命名
```bash
sudo EXTERNAL_URL="http://192.168.2.186" yum localinstall gitlab-ce-12.10.14-ce.0.el7.x86_64.rpm
rpm -ivh gitlab-ce-12.10.14-ce.0.el7.x86_64.rpm --force
```

### 3.启动gitlab
```bash
# (这一步是配置gitlab，时间比较久)
sudo gitlab-ctl reconfigure 
```
### 4.操作命令
```bash
gitlab-ctl start #启动全部服务
gitlab-ctl restart #重启全部服务
gitlab-ctl stop #停止全部服务
gitlab-ctl restart nginx #重启单个服务
gitlab-ctl status #查看全部组件的状态
gitlab-ctl show-config #验证配置文件
gitlab-ctl uninstall #删除gitlab(保留数据）
gitlab-ctl cleanse #删除所有数据，重新开始
gitlab-ctl tail <svc_name>  #查看服务的日志
gitlab-rails console production #进入控制台 ，可以修改root 的密码
gitlab-ctl reconfigure #使更改配置生效
```
