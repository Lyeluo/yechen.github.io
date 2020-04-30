## consul的配置
- 直接指定服务的 consul service id(即 instance id).  
- 默认情况下为 spring.application.name + server.port, 如果在多个服务器上同一个服务, 因为应用名和端口都一致, 会导致service id 会重复, 所以一般情况都需要引入一个随机数避免重复 .   
spring.cloud.consul.discovery.instance-id=${spring.application.name}-${random.value}   

- 指定服务的 consul service name   
spring.cloud.consul.discovery.service_name=some_name  

- consul 服务器主机名   
spring.cloud.consul.discovery.hostname=your_host  

- consul 服务器端口  
spring.cloud.consul.discovery.port=8500  

- 维护 tags  
$ 下面示例的 tag map 是:  foo->bar 和 baz->baz  
spring.cloud.consul.discovery.tags:foo=bar, baz  

- 是否启用服务发现   
spring.cloud.consul.discovery.enabled=true   

- 使用 consul 服务器 IP, 而不是 hostname, 需要搭配 prefer-ip-address 属性  
spring.cloud.consul.discovery.ip-address=127.0.0.1  

- 在注册时使用 consul IP, 而不是 hostname  
spring.cloud.consul.discovery.prefer-ip-address=false  

-设定 consul acl token 值  
spring.cloud.consul.discovery.acl-token=4efb1523-76a3-f476-e6d8-452220593089  

- 健康检查的频率, 默认 10 秒  
spring.cloud.consul.discovery.health-check-interval=10s  

- actuator 健康检查的 url 路径  
- 默认为 为${management.endpoints.web.base-path} +/health  
spring.cloud.consul.discovery.health-check-path=  
 
- 自定义健康检查的 url(适合于不适用 actuator 的场景)  
spring.cloud.consul.discovery.health-check-url=  

## 找不到服务
1. 首先测试监控服务的/actuator/health接口是否返回up
2. 调用接口http://192.168.12.184:30206/v1/agent/checks，查看consul调用health接口是否存在问题
