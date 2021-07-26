## 所需组件
- mysql
- redis
- nginx（k8s-pod）
- ecs-console(k8s-pod)
- ecs-job(k8s-pod)
## 部署步骤
1. 首先需要提前部署好mysql以及redis
2. 初始化数据库
    1. 初始化xxl-job的数据库脚本
    2. 初始化ecs控制台
3. 导入k8s yml文件
注意，在导入yml文件之前，需要修改以下参数：
- ecs-job-center的环境变量DB属性为之前部署的服务器属性
- ecs-console的环境变量JAVA_PARAM中的redis与db配置为之前部署的db与redis配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecs-console-nginx
  labels:
    app: ecs-console-nginx
spec:
  replicas: 1
  template:
    metadata:
      name: ecs-console-nginx
      labels:
        app: ecs-console-nginx
    spec:
      containers:
        - name: ecs-console-nginx
          image: 192.168.12.124:7080/ecs2/ecs-console-nginx:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: time
              mountPath: /etc/localtime
      restartPolicy: Always
      volumes:
        - name: time
          hostPath:
            path: /etc/localtime
  selector:
    matchLabels:
      app: ecs-console-nginx

---
apiVersion: v1
kind: Service
metadata:
  name: ecs-console-nginx
spec:
  selector:
    app: ecs-console-nginx
  ports:
    - port: 8080
      protocol: TCP
      targetPort: 8080
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecs-job-center
  labels:
    app: ecs-job-center
spec:
  replicas: 1
  template:
    metadata:
      name: ecs-job-center
      labels:
        app: ecs-job-center
    spec:
      containers:
        - name: ecs-job-center
          image: 192.168.12.124:7080/ecs-component/ecs-job-center:1.0.8
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8081
          env:
            - name: ECS_CONSOLE_URL
              value: http://ecs:8095/console/authApi/auth/isAuthorized
            - name: DB_USERNAME
              value: root
            - name: DB_URL
              value: 192.168.2.184:3306
            - name: DB_PASSWORD
              value: root
            - name: ACCESS_TOKEN
              value: ms-yuanian
      restartPolicy: Always
  selector:
    matchLabels:
      app: ecs-job-center
---
apiVersion: v1
kind: Service
metadata:
  name: ecs-job
spec:
  selector:
    app: ecs-job-center
  ports:
    - port: 8081
      protocol: TCP
      targetPort: 8081
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecs-console
  labels:
    app: ecs-console
spec:
  replicas: 1
  template:
    metadata:
      name: ecs-console
      labels:
        app: ecs-console
    spec:
      containers:
        - name: ecs-console
          image: 192.168.12.124:7080/ecs2/ecs-console:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8095
          env:
            - name: JAVA_PARAM
              value: "--spring.redis.host=192.168.2.184 --spring.datasource.url=jdbc:mysql://192.168.2.184:3306/ecs?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowMultiQueries=true&serverTimezone=Asia/Shanghai --spring.datasource.username=root --spring.datasource.password=root --yn.job.admin.addresses=http://ecs-job:8081/xxl-job-admin"
            - name: JAVA_OPT
              value: "-Xmx1024m -Xms1024m -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=256M -Dfile.encoding=utf-8 -Duser.timezone=GMT+8"
          volumeMounts:
            - name: time
              mountPath: /etc/localtime
      restartPolicy: Always
      volumes:
        - name: time
          hostPath:
            path: /etc/localtime
  selector:
    matchLabels:
      app: ecs-console
---
apiVersion: v1
kind: Service
metadata:
  name: ecs
spec:
  selector:
    app: ecs-console
  ports:
    - port: 8095
      protocol: TCP
      targetPort: 8095
  type: ClusterIP
```
4. 部署完成以后，可以从ecs-console-nginx中的nodeport端口访问控制台地址。默认管理员账号/密码为：console_super/123
5. 配置调度中心应用，配置方法参考文档 
注意：
- 文档中的ip:port即ecs-console-nginx中的nodeport端口与地址
- 此处的`运行报表` URL配置应修改为 http://ip:port/xxl-job-admin
