```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: test-redis
spec:
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        # 应用的镜像
        - image: 192.168.12.124:7080/ecs-component/ecs-redis:6.0
          name: redis
          imagePullPolicy: IfNotPresent
          # 持久化挂接位置，在docker中
          volumeMounts:
            - name: redis
              mountPath: /opt
      volumes:
        # 宿主机上的目录
        - name: redis
          nfs:
            # 此目录不一定必须是nfs的根目录，可以是nfs挂载目录的子目录
            path: /opt/data/tabase
            server: 192.168.2.187

```
