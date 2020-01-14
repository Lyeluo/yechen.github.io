## Downward API
### 通过环境变量暴露元数据
pod的模板定义
```yaml
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: CONTAINER_CPU_REOUEST_MILLICORES
              valueFrom:
                # 对于容器的CPU和内存的环境变量使用resourceFieldRef字段
                resourceFieldRef:
                  resource: requests.cpu
                  # 设置基础单位（对于CPU，1m即千分之一的CPU）
                  divisor: 1m
```
这种方式会将pod的信息添加在环境变量中，方便容器中的服务或者使用脚本的方式获得这些信息。
### 通过downwardAPI传递元数据
pod会在容器中的/etc/downward创建多个文件,每个文件的名称为items.path的值。如：会在/etc/downward/下创建一个podName文件，保存metadata.name的值  

```yaml
    spec:
      imagePullSecrets:
        - name: mydockerhubsecret
      containers:
        - name: app
          image: app/1.0
          ports:
            - containerPort: 8080
          volumeMounts:
          # 挂载到容器中的目录
            - mountPath: /etc/downward
              name: downward
      volumes:
        - name: downward
          downwardAPI:
            items:
              - path: "podName"
                fieldRef:
                  fieldPath: medatata.name
              - path: "podNamespace"
                fieldRef:
                  fieldPath: medatata.namespace
              - path: "labels"
                fieldRef:
                  fieldPath: medatata.labels
              - path: "annotations"
                fieldRef:
                  fieldPath: medatata.annotations
              - path: "containerCpuRequestMilliCores"
                resourceFieldRef:
                  resource: requests.cpu
                  # 对于CPU和内存限制，containerName必须填写
                  containerName: app
                  divisor: 1m
              - path: "containerMemoryLimitBytes"
                resourceFieldRef:
                  resource: limits.memory
                  # 对于CPU和内存限制，containerName必须填写
                  containerName: app
                  divisor: 1m
```
可以在pod运行时修改labels、annotation等数据，kubernetes会自动刷新这些数据对应的文件。使用环境变量的方式就无法达到这种效果    
使用这种方式，会将pod的信息存储在文件中，但是这种方式获得的数据是有限的。  
