1.首先创建账号  
useradd ${userName}  
2.修改密码  
passwd ${userName}  
3.创建docker组  
```bash
groupadd docker
```
4.将用户加入docker组
```bash
usermod -aG docker ${userName}
```
5.重启docker服务
```bash
systemctl restart docker
```
6.需要切换账号才能使配置生效  

切换超级管理员用户  
su root  
切换为当前创建的账户  
su ${userName}  
