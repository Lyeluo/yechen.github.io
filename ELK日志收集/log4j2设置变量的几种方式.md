### 1.获取maven中的配置
pom文件中添加属性配置  
除了配置在properties中也可以配置在<profile>标签中
```xml
<properties>
<app.log.serviceName>exporter</app.log.serviceName>
</properties>
```
log4j2.yml文件中引用
```yml
  properties:
    property:
      - name: serviceName
        value: ${app.log.serviceName} 
```
备注:
- 此种使用方式log4j2.yml文件必须放在项目中，即classpath下
### 2.启动应用时通过传入VM options
在springboot应用启动时，添加启动参数，如：`-Dapp.log.serviceName=exporter`   
指定外置log4j2.yml配置文件同样适用此种方式，如：`-Dlogging.config=D:\temp\log4j2.yml`
log4j2.yml文件中引用
```yml
  properties:
    property:
      - name: serviceName
       # 注意格式必须是 ${sys:}
        value: ${sys:app.log.serviceName}  
```
