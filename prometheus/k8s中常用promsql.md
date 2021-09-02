### k8s监控指标信息
````
#节点CPU使用量
(1 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) by (node))) * 100

#节点内存使用量
100-((node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes))*100

#节点入口流量
rate(node_network_receive_bytes_total{device="eth0"}[5m])/1024/1024

#节点出口流量
rate(node_network_transmit_bytes_total{device="eth0"}[5m])/1024/1024

#节点系统盘使用量
(1 - (node_filesystem_free_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100

#节点数据盘使用量
(1 - (node_filesystem_free_bytes{mountpoint="/data"} / node_filesystem_size_bytes{mountpoint="/data"})) * 100

#Http状态码监测
((istio_requests_total{source_workload_namespace!~"crond",destination_service_namespace!~"cattle-prometheus|cattle-system|istio-system|kube-system|crond",response_code!~"200|301|302|304|404|405|500",destination_service!~"51ykb.govbuy.cn"}offset 1s)-(istio_requests_total{source_workload_namespace!~"crond",destination_service_namespace!~"cattle-prometheus|cattle-system|istio-system|kube-system|crond",response_code!~"200|301|302|304|404|405|500"}offset 120s))

#Pod调度状态监测
kube_pod_status_scheduled{namespace!~"cattle-prometheus|cattle-system|istio-system|kube-system",condition="false"}

#Pod重启状态监测
kube_pod_container_status_restarts_total{namespace!~"cattle-prometheus|cattle-system|istio-system|kube-system"}

#内存申请与控制差值监控
(kube_pod_container_resource_limits_memory_bytes{namespace!~"cattle-prometheus|cattle-system|istio-system|kube-system",container!~"istio-proxy"} - kube_pod_container_resource_requests_memory_bytes{namespace!~"cattle-prometheus|cattle-system|istio-system|kube-system"}) > 0

#发布失败
kube_deployment_status_replicas_unavailable > 0
````
### py组件告警路径
```python
    path('', Controller.home),
    path('index', Controller.index),
    path('pod', Controller.pod),
    path('alert/node/cpu', Controller.nodecpu),
    path('alert/node/memory', Controller.nodememory),
    path('alert/node/in', Controller.nodein),
    path('alert/node/out', Controller.nodeout),
    path('alert/node/sysdisk', Controller.nodesysdisk),
    path('alert/node/datadisk', Controller.nodedatadisk),
    path('alert/pod/httpcode', Controller.podhttpcode),
    path('alert/pod/schedul', Controller.podschedul),
    path('alert/pod/restart', Controller.podrestart),
```



