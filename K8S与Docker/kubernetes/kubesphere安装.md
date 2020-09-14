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

## 安装遇见的问题

### 1.kubesphere 监控容器起不来
```bash
kubesphere-controls-system     default-http-backend-6555ff6898-hngd6          1/1     Running             0          32h     10.244.221.212   kube-master   <none>           <none>
kubesphere-controls-system     kubectl-admin-74fdfc47c7-pjvgf                 1/1     Running             0          32h     10.244.221.224   kube-master   <none>           <none>
kubesphere-monitoring-system   grafana-b4999c5b7-ss7vd                        1/1     Running             0          32h     10.244.221.220   kube-master   <none>           <none>
kubesphere-monitoring-system   kube-state-metrics-7c4d6675b-gnh4f             4/4     Running             0          45m     10.244.9.65      kube-node1    <none>           <none>
kubesphere-monitoring-system   node-exporter-bjpc6                            2/2     Running             0          45m     192.168.12.186   kube-node2    <none>           <none>
kubesphere-monitoring-system   node-exporter-gp4fr                            2/2     Running             0          86m     192.168.12.185   kube-node1    <none>           <none>
kubesphere-monitoring-system   node-exporter-q6psj                            2/2     Running             0          32h     192.168.12.184   kube-master   <none>           <none>
kubesphere-monitoring-system   prometheus-k8s-0                               3/3     Running             1          32h     10.244.221.223   kube-master   <none>           <none>
kubesphere-monitoring-system   prometheus-k8s-system-0                        0/3     ContainerCreating   0          21m     <none>           kube-master   <none>           <none>
kubesphere-monitoring-system   prometheus-operator-545df648fb-cvb22           1/1     Running             0          32h     10.244.221.219   kube-master   <none>           <none>

```
查看事件发现报错
报错
```bash
Events:
  Type     Reason       Age                  From                  Message
  ----     ------       ----                 ----                  -------
  Normal   Scheduled    24m                  default-scheduler     Successfully assigned kubesphere-monitoring-system/prometheus-k8s-system-0 to kube-master
  Warning  FailedMount  2m8s (x10 over 22m)  kubelet, kube-master  Unable to mount volumes for pod "prometheus-k8s-system-0_kubesphere-monitoring-system(e9d48f73-d95d-43cb-ab49-ae9944ca2d6a)": timeout expired waiting for volumes to attach or mount for pod "kubesphere-monitoring-system"/"prometheus-k8s-system-0". list of unmounted volumes=[secret-kube-etcd-client-certs]. list of unattached volumes=[prometheus-k8s-system-db config tls-assets config-out prometheus-k8s-system-rulefiles-0 secret-kube-etcd-client-certs prometheus-k8s-token-fdfzq]
  Warning  FailedMount  2m7s (x19 over 24m)  kubelet, kube-master  MountVolume.SetUp failed for volume "secret-kube-etcd-client-certs" : secret "kube-etcd-client-certs" not found
```
解决方式，安装secret
```bash
kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
```
参考地址：https://github.com/kubesphere/ks-installer
