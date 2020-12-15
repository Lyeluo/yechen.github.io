```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: SERVICE_NAME
  namespace: NAMESPACE
spec:
  selector:
    matchLabels:
      app: SERVICE_NAME
  replicas: 1
  template:
    metadata:
      labels:
        app: SERVICE_NAME
        version: "VERSION"
    spec:
      nodeSelector:
        productLine: ai
      tolerations:
        - key: productLine
          value: "ai"
          effect: "NoSchedule"
      containers:
        - name: ai
          image: registry.cn-hangzhou.aliyuncs.com/xubin/ai_platform_test:v1
          imagePullPolicy: Never
          # 开启后类似与docker run 的-it,就是 Linux 给用户提供的一个常驻小程序
          tty: true
          # 为了能够在 tty 中输入信息，你还需要同时开启 stdin（标准输入流）
          stdin: true
          lifecycle:
            # 容器启动后执行的命令
            postStart:
              exec:
                command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
            # 容器停止前执行的命令    
            preStop:
              exec:
                command: ["/usr/sbin/nginx","-s","quit"]
          resources:
            requests:
              cpu: 4
              memory: 4G
            limits:
              cpu: 4
              memory: 4G
```
