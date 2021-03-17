集成springboot actuator到Prometheus参考地址： https://juejin.cn/post/6844903975196573710

首先springboot 项目中引入包
```xml
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
```
然后配置文件中添加配置
```yml
management:
  endpoints:
    web:
      exposure:
        include: "*"
  endpoint:
    health:
      show-details: ALWAYS
```
然后访问路径`/actuator/prometheus` 即可
