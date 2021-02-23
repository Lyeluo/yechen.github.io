### 下面安装之后可以下载包到本地指定目录而不直接安装
```bash
yum install yum-plugin-downloadonly
 
yum install docker-ce --downloadonly --downloaddir=/home/zhangyong/yum/
```
然后就可以去/home/zhangyong/yum/查看 rpm包了。
```bash
cd /home/zhangyong/yum

```
 
### 安装下载的rpm包
```bash
rpm -Uvh --force --nodeps ./*.rpm
```
### 启动docker服务
```bash
systemctl start docker.service
 
docker -v
```
