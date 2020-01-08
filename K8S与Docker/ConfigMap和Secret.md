## 向容器中传递参数
在kubernetes创建容器时，镜像Dockerfile中的ENTRYPOINT和CMD都可以被覆盖，方法如下：
```yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          command: ["/bin/command"]
          # 少量参数时可以采用数组的方式，大量参数可以使用本种方式
          # 参数为字符串时不用管，为数值时需要加引号
          args:
            - foo
            - "15"
          ports:
            - containerPort: 8080
```
|Docker  | kubernetes|  描述| 
|:------- |:-------|:-------|
| ENTRYPOINT | command |容器中运行的可执行文件  | 
| CMD | args | 传给可执行文件的参数 |  
## 通过环境变量配置
```yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          env:
            - name: VAR
              value: "foo"
              # 环境变量可以通过${}互相引用
            - name: VAR_2
              value: ${VAR}_2
          ports:
            - containerPort: 8080
```
## ConfigMap
ConfigMap可以提供一些基础的配置交由kubernetes使用${}的方式进行调用，这样的话可以做到对用户无感知。
同时，在不同的命名空间创建同名的ConfigMap可以达到多环境部署的效果。  
创建ConfigMap，只能通过`kubectl create configmap`而不是kubectl create -f  
以下是kubectl创建的各种方式
```bash
kubectl create configmap my-config
  --from-file=foo.json
  --from-file=bar=foo.config
  --from-file=config-opts/
  --from-literal=some=thing
```
![config的几种创建方式生成的键值对](../images/1577951749(1).jpg)  
引用configmap的几个键值对作为环境变量
```yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          env:
            - name: VAR
              valueFrom:
                configMapKeyRef:
                 # 如果引用的configmap不存在，pod会正常创建但是容器创建会失败，
                 # 当configmap创建后，容器会自动创建
                 # 但是如果设置 optional: true 则即便configmap不存在容器也会正常创建
                  optional: true                
                # configmap的名称
                  name: my-config
                  # 上面选择的configmap的键值
                  key: var_value
          ports:
            - containerPort: 8080
```
将整个configmap中的键值对作为环境变量
````yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          envFrom:
            # 可以通过prefix为config中的键值加统一的前缀
            - prefix: CONFIG_
              configMapRef:
                name: my-config
          ports:
            - containerPort: 8080
````
如果configmap中的键名格式不对，kubernetes会自动将其忽略，并且不会提示。  
若是想要将configmap中的键值对作为参数传递给Dockerfile作为变量，可以先读取configmap，然后将这个环境变量传给容器
```yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          # 这里的参数与下面的env命名一致
          args:
            - ${VAR}
          env:
            - name: VAR
              valueFrom:
                configMapKeyRef:
                  name: my-config
                  key: var_value
          ports:
            - containerPort: 8080
```
## 将configmap作为容器的挂载卷
从上面可以知道，configmap可以读取一整个文件或者文件下下的所有文件，键名为文件名，键值为文件内容
这样可以将整个文件读取到config中，然后作为容器的挂载卷。
```yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          volumeMounts:
            - mountPath: /etc/nginx/conf.d
              name: config
          ports:
            - containerPort: 8080
      volumes:
        - name: config
          configMap: 
            name: my-config
            # 传入挂在卷的同时设置文件权限
            defaultMode: "6600"            
            # 指定挂载卷读取的键名
            items:
              - key: nginx-config.conf
              # 读取出来的键值存储的文件名
                path: nginx.conf            
```
上面这个yaml文件，会将my-config中键名为nginx-config.conf的键值，生成名为nginx.conf的文件，然后放在容器中的/etc/nginx/conf.d目录下。  

+ 注意：linux系统中使用挂载的方式，会使挂载目录下的原有文件被隐藏而不可访问。如/etc/nginx/conf.d目录下只可以看到nginx.conf文件，其余文件都不可访问
+ 可以使用volumeMounts的subPath仅挂载部分卷，这样原有的文件就不会被隐藏，subPath未配置的文件也不会挂载
```yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          volumeMounts:
            - mountPath: /etc/someconfig.conf
              name: config
              subPath: myconfig.conf
```
![configmap作为挂载卷](../images/1577955313(1).jpg)  

使用configmap作为挂载卷时，如果configmap发生了变化会自动同步到容器中，可能会耗时几分钟，但是也可以通过主动通知kubernetes的方式
主动刷新。

如果挂载的是容器中的单个文件而不是整个卷，那么configmap更新后对应的文件不会被更新（不确定目前最新版本是否还是这样）  
## 使用 Secret给容器传递敏感数据
Secret的使用方法与configmap相同，不过Secret只会被分发到需要访问Secret的pod所在的机器节点上，而且只会存储在内存中。  
+ 采用 ConfigMap 存储非敏感的文本配置数据。
+ 采用 Secret 存储天生敏感的数据，通过键来引用。 如果一个配置文件同时包含敏感与非敏感数据， 该文件应该被存储在 Secret 中
1. 创建secret  
`kubectl create secret generic fortune-https --from-file=https.key`  
创建方式与configmap基本相同，这里是创建了一个generic的Secret

2. secret与configmap的区别  
secret以Base64的格式来存储文本信息；configmap以文本格式存储文本信息。这样的话对于yaml或者json格式的文件，在使用kubectl命令展示secret的时候就需要
进行转义，而且secret存储文本信息的大小为1MB。
  
备注：在使用pod读取secret时，不需要进行转义，可以直接使用。  
3. kubernetes允许secret使用纯文本值。可以通过StringData字段实现。
4. 在pod中使用secret
```yaml
    spec:
      containers:
        - name: app
          image: app/1.0
          volumeMounts:
            - mountPath: /etc/someconfig.conf
              name: certs
              subPath: myconfig.conf
              readOnly: true
          ports:
            - containerPort: 8080
      volumes:
        - name: certs
          secret:
            secretName: nainx-config
```
与configmap一样secret也支持在挂载的同时对文件赋予文件权限。  
5. 使用secret创建环境变量。  
因为环境变量的方式并不安全，可以有很多种方式被获取，所以这里就不介绍了。
6.  docker hub私有仓库配置secret  
   1. 创建docker-registry类型的secret`kubectl create secret docker-registry mydockerhubsecret --docker-username=root --docker-password=root --docker-email=yechen@yuanian.com`
   2. 配置pod，这样的话在私有仓库拉取代码的时候，会自动进行登陆。后面会有更好的办法，所以不需要为每一个pod创建secret
   ```yaml
        spec:
          imagePullSecrets:
            - name: mydockerhubsecret
          containers:
            - name: app
              image: app/1.0
              ports:
                - containerPort: 8080
    ```
   
 

