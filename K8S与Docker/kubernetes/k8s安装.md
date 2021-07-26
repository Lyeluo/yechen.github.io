## 1.安装Docker
[Docker安装](./docker-install.sh)
## 2.安装 Kubeadm
### 安装 Kubeadm 主要有以下三个步骤：

> 配置 Kubernetes 的 yum 仓库源（这里选用阿里的源，你懂的）  
  安装 Kubeadm 和相关工具  
  启动 Kubelet  
  设置 Kubernetes 的 yum 仓库源  

#### 1.阿里云源（推荐）
```bash
tee /etc/yum.repos.d/kubernetes.repo <<-'EOF'
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

#### 官方源（不推荐）
```bash
tee /etc/yum.repos.d/kubernetes.repo <<-'EOF'
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
```

#### 2.安装 Kubeadm 和相关工具

```bash
yum install -y kubelet-1.15.0 kubeadm-1.15.0 kubectl-1.15.0
```
#### 3.启动 Kubelet
```bash
systemctl start kubelet && systemctl enable kubelet
```

## 3.基础环境配置(所有主机)
基础环境配置，主要执行以下步骤：

>1.设置各节点时间精确同步  
2.关闭 firewalld/iptables 防火墙  
3.关闭 SElinux 安全模组  
4.关闭 Swap 交换分区  
5.导入 IPVS 模块  
6.修改 Bridge 桥接规则  
7.开启 iptables 的 FORWARD 转发链  
8.配置 Hosts 解析 
 
### 设置各节点时间精确同步  
```bash
systemctl start chronyd.service && systemctl enable chronyd.service
```

### 关闭 firewalld 防火墙（允许 master 和 node 的网络通信）
由于 Master 和 Node 存在大量网络交互，需对防火墙进行相关配置

- 外网环境：在防火墙上配置各组件相互通信的端口
- 内网环境：直接关闭防火墙，减少防火墙规则的维护工作
```bash
systemctl stop firewalld && systemctl disable firewalld
```
### 关闭 SElinux 安全模组（让容器可以读取主机的文件系统）
```bash
setenforce 0 && sed -i "s/SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config
```
### 关闭 Swap 交换分区（启用了 Swap，则 Qos 策略可能会失效）
```bash
swapoff -a && sed -i "s/\/dev\/mapper\/centos-swap/\#\/dev\/mapper\/centos-swap/g" /etc/fstab
```
### 导入 IPVS 模块（用来为大量服务进行负载均衡）
```bash
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

### 修改 Bridge 桥接规则（部分 Docker 安装时会为我们修改，这里统一进行手动修改）
```bash
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl --system
```

### 开启 iptables 的 FORWARD 转发链（Docker 1.13 后禁用了 FORWARD 链，这可能会引起 Pod 间无法通信）
```bash
iptables -P FORWARD ACCEPT
sed -i '/ExecStart/a ExecStartPost=/sbin/iptables -P FORWARD ACCEPT' /usr/
lib/systemd/system/docker.service
systemctl daemon-reload
```

### 配置 Hosts 解析（添加 k8s 所有节点的 IP 和对应主机名，否则初始化的时候会出现告警甚至错误）
```
tee /etc/hosts <<-'EOF'
::1     localhost       localhost.localdomain   localhost6      localhost6.localdomain6
127.0.0.1       localhost       localhost.localdomain   localhost4      localhost4.localdomain4
192.168.12.184 kube-master
192.168.12.185 kube-node1
192.168.12.186 kube-node2
EOF
```

### 安装一些必要的工具（这些工具在以后的命令中会用到）
```bash
yum install -y ipset \
yum install -y ipvsadm \
yum install -y bind-utils
```

### 修改hostname
```bash
hostnamectl set-hostname kube-master
```

## 安装Kubernetes
### 1.初始化 Master 节点
使用 `kubeadm config print init-defaults > kubeadm-init.yaml` 获取初始配置文件进行相应的自定义修改  
然后使用 `kubeadm init --config kubeadm-init.yaml`，通过配置文件进行初始化  
```yaml
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
 # Master主机地址
  advertiseAddress: 192.168.12.184
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: kube-master
  taints:
    # 污点策略
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
# 镜像仓库    
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
# k8s版本
kubernetesVersion: v1.15.0
networking:
  dnsDomain: cluster.local
  # pod的ip范围
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler: {}
```
执行成功则会得到如下结果
```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:
## 这一段一定保留好，注册node节点时要用
kubeadm join 192.168.12.184:6443 --token a0rzmd.acseqn14kiwenhqd \
    --discovery-token-ca-cert-hash sha256:bd5ef2e95e64665f899a2fb616979b2a3e2fdf5fd544b49234f81fbc7f54e94b 

```
### 复制文件到master及node目录
```bash
# 拷贝配置文件到 Master 节点
mkdir /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

# 分发配置文件到各 Node 节点（让 Node 节点使用 `kubectl`）

scp /etc/kubernetes/admin.conf KubernetesNode1:/root/.kube/config
scp /etc/kubernetes/admin.conf KubernetesNode2:/root/.kube/config
```
### 安装 CNI 网络插件

~~1.Flannel 插件~~
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

2.Calico 插件（安装了这个 Flannel就不必安装了）
```bash
## 版本v3.8
kubectl apply -f calico.yaml
```
[calico.yaml v3.8.2](./calico.yaml)

[安装calico-cli](./calico-cli安装.md)    
3.检查 Master 的 Pod 及 集群状态  

使用 `kubectl get pod -n kube-system -o wide`，查看 Pod 状态均为 Runing 即可  
使用 `kubectl get node -o wide`，查看 Node 状态为 Ready 表示 Master 初始化完成  

## 2. 初始化 Node 节点
初始化 Node 节点就比较简单了，只有两步，即：

### 执行初始化
>检查 Node 的 Pod 及 集群状态  
1.初始化 Node  
2.使用 Master 初始化时的命令进行初始化即可，Node 节点初始化后，就直接加入了集群  

```bash
kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<sha256>
```
注意：没有记录集群 join 命令的可以通过以下方式重新获取

```bash
sudo kubeadm token create --print-join-command --ttl=0
```
检查 Node 的 Pod 及 集群状态  

使用 `kubectl get pod -n kube-system -o wide`，查看 Pod 状态均为 Runing 即可  
使用 `kubectl get node -o wide`，查看 所有节点 状态均为 Ready 表示 Master 初始化完成  

## 4.重置 Kubernetes 集群

在集群安装失败，或者出现一些无法解决的问题时，可以重置集群，再重新安装
重置 Kubernetes 集群，主要的执行步骤如下：

>1.kubeadm 集群重置  
2.iptables 规则清理  
3.ipvs 规则清理  
4.kubernetes 配置文件清理  
5.etcd 配置清理  
6.cni 网络插件清理  

```bash
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
ipvsadm --clear
rm -rf ~/.kube
rm -rf /var/lib/etcd
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/
```

借鉴地址：  
https://www.jianshu.com/p/789bc867feaa  
https://blog.51cto.com/zlyang/2425318      
