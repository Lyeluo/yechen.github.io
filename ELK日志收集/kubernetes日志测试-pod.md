# kubernetes日志回滚测试
|    操作节点     | podName| 查询日志的命令 | 得到结果 | 
| :---------- | :--- | :--- | :--- |
| 初始pod | ms-zipkin-deployment-5949c78884-4x5h7 | kubectl logs ms-zipkin-deployment-5949c78884-4x5h7 --namespace=ecs2 | 完整日志 |
| 操作容器崩溃，使k8s自动重建容器 | ms-zipkin-deployment-5949c78884-4x5h7 | kubectl logs ms-zipkin-deployment-5949c78884-4x5h7 --namespace=ecs2 --previous | 上个版本容器日志 + 操作容器崩溃的命令 |
| 手动回滚pod | ms-zipkin-deployment-54f87bb4dc-hk6v8 | kubectl logs ms-zipkin-deployment-54f87bb4dc-hk6v8 --namespace=ecs2 --previous | 提示找不到历史pod |

## 结论
+ 容器挂掉后自动重启，pod不会重新创建，podname不会发生变化，k8s保留上次挂掉容器的日志信息
+ 手动重新部署，podname发生变化，不能获取到上次容器崩溃时的日志信息
