1.删除悬空镜像（镜像名称或者tag为空的镜像）  
```docker rmi $(docker images -f "dangling=true" -q)```
