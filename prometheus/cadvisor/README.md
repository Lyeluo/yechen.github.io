### 整体介绍
为了解决容器的监控问题，Google开发了一款容器监控工具cAdvisor（Container Advisor），它为容器用户提供了对其运行容器的资源使用和性能特征的直观展示。 
它是一个运行守护程序，用于收集，聚合，处理和导出有关正在运行的容器的信息。
###启动命令
```bash
 docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  google/cadvisor
```
