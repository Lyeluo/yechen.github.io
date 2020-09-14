## 下载安装calico-ctl
```bash
cd /usr/local/bin;
curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.8.2/calicoctl;
chmod +x calicoctl;
```
## 配置calicoctl连接到kubernetes API，这里使用最简单的命令行形式，如下：
```bash
 DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl [命令]
```
## 配置别名
```bash
alias k8s-calicoctl='DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl'
```
### 查看目前支持的ip池
```bash
[root@kube-master 04.cni-network]# k8s-calicoctl get ippool -o wide 
NAME                  CIDR            NAT    IPIPMODE   VXLANMODE   DISABLED   SELECTOR   
default-ipv4-ippool   10.244.0.0/16   true   Always     Never       false      all()   
```
