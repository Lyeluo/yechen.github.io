## 1.安装helm
下载helm二进制文件 https://get.helm.sh/helm-v2.10.0-linux-amd64.tar.gz
### 1.1解压
```bash
tar -zxvf helm-v2.10.0-linux-amd64.tar.gz
```
### 1.2copy到path路径下
```bash
cp linux-amd64/helm /usr/local/bin
```
## 2.安装tiller
由于tiller需要访问api-server，而api-server设置了访问权限，
因此，需要给tiller设置权限
### 2.1创建serviceaccount
```bash
kubectl -n kube-system create serviceaccount tiller
```
### 2.2创建角色
```bash
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
```
### 2.3准备好镜像
tiller版本，最好跟客户端helm的版本保持一致  
可能需要翻墙拉取镜像
### 2.4开始安装tiller
```bash
helm init --service-account=tiller --tiller-image=gcr.io/kubernetes-helm/tiller:v2.14.1 --skip-refresh --history-max 300
```

安装helm参考地址：https://www.jianshu.com/p/2a96b06febc6

