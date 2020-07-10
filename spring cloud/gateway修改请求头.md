## spring cloud gateway 全局过滤器修改请求头
```java
package com.mbase.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpRequestDecorator;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Consumer;

/**
 * @author liujy
 * @date 2020/7/9 11:09
 **/
@Component
public class FeignSignatureFilter implements GlobalFilter, Ordered {

    static Logger logger = LoggerFactory.getLogger(FeignSignatureFilter.class);

    private static final String SERVICE_SECRET_KEY = "liujySecret";

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {

        ServerHttpRequest request = exchange.getRequest();
        HttpHeaders headers = request.getHeaders();
        boolean b = headers.containsKey(SERVICE_SECRET_KEY);
        if (!b) {
            // 如果头信息不包含SERVICE_SECRET_KEY，直接放行
            return chain.filter(exchange);
        }
        if (logger.isDebugEnabled()) {
            logger.debug("请求中携带SERVICE_SECRET_KEY，请注意是否为恶意攻击，请求信息：{}", request.toString());
        }

        ServerHttpRequestDecorator serverHttpRequestDecorator = new ServerHttpRequestDecorator(exchange.getRequest()) {
            @Override
            public HttpHeaders getHeaders() {
                HttpHeaders httpHeaders = new HttpHeaders();
                httpHeaders.putAll(super.getHeaders());
                httpHeaders.remove(SERVICE_SECRET_KEY);
                return httpHeaders;
            }
        };

        return chain.filter(exchange.mutate().request(serverHttpRequestDecorator).build());

    }

    @Override
    public int getOrder() {
        return -10;
    }
}

```
