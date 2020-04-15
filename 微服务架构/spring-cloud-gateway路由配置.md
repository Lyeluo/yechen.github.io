## 引入依赖
```xml  
        <!--    网关       -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
        <!--    hystrix熔断       -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
        </dependency>
        <!--    redis限流       -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis-reactive</artifactId>
        </dependency>
```

## 配置文件
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: ecs-gl
          uri: lb://ms-business-gl
          predicates:
            - Header=appId,9a790a42de7e11e9800789881a87ab27
          #            - Path=/fssc/gl/**
          filters:
            #  限流配置
            - name: RequestRateLimiter
              args:
                # 获取令牌的逻辑
                key-resolver: '#{@defaultResolver}'
                # 每秒填充速率
                redis-rate-limiter.replenishRate: 1
                # 桶容量
                redis-rate-limiter.burstCapacity: 5
            # 熔断配置    
            - name: Hystrix
              args:
                name: glHystrix
                # 降级
                fallbackUri: forward:/defaultfallback
              # 添加响应头  
            - AddResponseHeader=serviceName, ms-business-gl
```

注意：顺序不能乱，限流要在熔断的上面。否则webflux会报错
## redis配置
```yaml
spring:
  redis:
    host: 192.168.12.184
    port: 32459
    database: 1
    password:
```
## hystrix配置
```yaml
hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            # 全局熔断器5s超时
            timeoutInMilliseconds: 15
```
## 启动类
```java
package com.yuanian.micro;

import com.yuanian.micro.config.DefaultResolver;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication(scanBasePackages = "com.yuanian.micro")
public class App {

	public static void main(String[] args) {
		SpringApplication.run(App.class, args);
	}

	@Bean(name = "defaultResolver")
	public DefaultResolver defaultResolver(){
		return new DefaultResolver();
	}
}
```
## defaultResolver
```java
package com.yuanian.micro.config;

import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

/**
 * @author liujy
 * @date 2020/3/27 9:55
 **/
public class DefaultResolver implements KeyResolver {
    @Override
    public Mono<String> resolve(ServerWebExchange exchange) {
        String hostAddress = exchange.getRequest().getRemoteAddress().getAddress().getHostAddress();
        String path = exchange.getRequest().getPath().toString();
        return Mono.just(hostAddress + path );
    }
}
```
## 降级接口
```java
package com.yuanian.micro.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * @author liujy
 * @date 2020/3/26 22:08
 **/
@RestController
public class DefaultFallBackController {


    @GetMapping("/defaultfallback")
    public Map<String, Object> fallback(){
        HashMap<String, Object> map = new HashMap<>();
        map.put("data", null);
        map.put("message", "服务异常");
        map.put("messageList", null);
        map.put("messageType", "ERROR");
        map.put("success", false);

        return map;
    }


}
```
