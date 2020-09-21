## consul + boot admin
在适配springboot admin + consul时，如果服务配置了context-path，springboot admin调用时默认不会带着context-path.
## 监控端点设置
```yaml
management:
  endpoints:
    web:
      exposure:
        include: "*"
  endpoint:
    health:
      show-details: ALWAYS
```
## 需要在服务注册配置上添加如下配置
### consul + boot admin
```yaml
spring:
  cloud:
    consul:
      discovery:
        tags: management.context-path=${server.servlet.context-path}/actuator
```
### nacos + boot admin
```yaml
spring:
  cloud:
    nacos:
      discovery:
        metadata:
          management:
            context-path: ${server.servlet.context-path}/actuator
```
### eureka + boot admin
```yaml
eureka:
  instance:
    metadata-map:
      management:
        context-path: ${server.servlet.context-path}/actuator
```

