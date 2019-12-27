## Service
1. 创建方式
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app
spec:
  # 可以通过配置sessionAffinity将监听到的来自同一ClientIp的请求转发到同一个pod上
  sessionAffinity: ClientIp
  ports:
    # 监听容器的80端口
    - port: 80
    # 将监听到的80端口的请求转发到内部服务的8080端口上
      targetPort: 8080
  selector:
    app: app
```
2. 如果需要配置多个端口，增加ports下的port即可，但是需要注意 所有的pod必须使用同一个标签选择器，如果要使用不同的标签选择器
需要创建多个service服务才可以  
 ```yaml
spec:
  ports:
    - name: service
      port: 18103
      targetPort: 18103
    - name: debug
      port: 18203
      targetPort: 18203
      nodePort: 32202
  selector:
    app: IMAGE_NAME
```
3. 可以通过在pod中对端口命名的方式，来与service进行匹配，这样就相当于降低了端口的耦合
```yaml
# service
spec:
  ports:
    - name: service
      port: 18103
      targetPort: service
---   
# pod
spec : 
  containers: 
    - name: kubia
  ports : 
    - name : service 
      containerPort 8080
```
4. 对于同一个命名空间下的服务，可以直接通过服务名称访问；对于不同命名空间的服务，需要添加命名空间.集群域后缀，如下：  
```bash
backend-database.default.svc.cluster.local
```
+ backend-database:服务名称
+ default：命名空间名称
+ svc.cluster.local 集群域名称
