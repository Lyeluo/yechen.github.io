# kubernetes机理
### 结构图
1. 控制平面的组件
   
   - etcd分布式持久化存储
   - API服务器
   - 调度器
   - 控制器管理器  
这些组件用来存储、管理集群的状态，但是他们并不是容器   
2. 工作节点上运行的组件
   
   - kubelet：Kubelet 是唯一一直作为常规系统组件来运行的组件 ，它把其他组件作为pod来运行。所以必须部署在master上
   - kubelet服务代理（kube-proxy）
   - 容器运行时（Docker、rkt或其他）  
   运行容器的任务依赖于每个工作节点上运行的组件
3. 附加组件
   
   - kubernetes DNS服务器
   - 仪表盘
   - Ingress控制器
   - Heapster（容器集群监控）
   - 容器网络接口插件
![k8s结构图](../images/1594002218(1).jpg)

## 没整明白的地方  
![k8s结构图](../images/1594090404(1).jpg)  
