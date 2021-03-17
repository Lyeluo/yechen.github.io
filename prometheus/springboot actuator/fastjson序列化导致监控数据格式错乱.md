在springboot 中集成prometheus的监控时遇见问题。  
因为项目里在`StaticResourceConfig`配置了fastjson 序列化，导致prometheus接口返回数据被转化为json格式，无法正常展示  
StaticResourceConfig 配置如下:
```
    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        for (HttpMessageConverter<?> converter : converters) {
            if (converter instanceof MappingJackson2HttpMessageConverter) {
                converters.remove(converter);
            }
        }
        converters.add(new ByteArrayHttpMessageConverter());
        converters.add(getFastJsonConverter());
    }

    private FastJsonHttpMessageConverter getFastJsonConverter() {
        FastJsonHttpMessageConverter converter = new FastJsonHttpMessageConverter();
        List<MediaType> supportedMediaTypes = new ArrayList<>();
        //提供对admin的类型支持mediaType
        MediaType mediaType = MediaType.valueOf("application/vnd.spring-boot.actuator.v2+json");
        supportedMediaTypes.add(mediaType);
        supportedMediaTypes.add(MediaType.ALL);
        converter.setSupportedMediaTypes(supportedMediaTypes);
        FastJsonConfig fastJsonConfig = new FastJsonConfig();
        fastJsonConfig.setSerializerFeatures(SerializerFeature.WriteDateUseDateFormat,
                SerializerFeature.WriteNullStringAsEmpty,
                SerializerFeature.WriteMapNullValue,
                SerializerFeature.DisableCircularReferenceDetect);
        //日期格式化
        fastJsonConfig.setDateFormat("yyyy-MM-dd HH:mm:ss");
        ParserConfig parserConfig = ParserConfig.getGlobalInstance();
        parserConfig.setSafeMode(true);
        fastJsonConfig.setParserConfig(parserConfig);
        converter.setFastJsonConfig(fastJsonConfig);

        return converter;
    }
```

通过增加一层转发，调用监控接口获取到数据，然后反序列化为原来的格式，然后通过`response.write`方式返回监控结果。  
因为采用`response.write`的方式，不会被spring mvc的HttpMessageConverter所拦截，所以可以直接返回`plain/text`格式的数据
```java
package com.yuanian.monitor;

import com.alibaba.fastjson.JSON;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import javax.servlet.http.HttpServletResponse;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.net.URISyntaxException;

/**
 * @author liujy
 * @since Wed Feb 24 17:55:16 CST 2021
 */
@RestController
@RequestMapping("prometheus")
public class PrometheusController {
    @Value("${server.servlet.context-path}")
    private String contextPath;
    @Value("${server.port}")
    private Integer port;

    @GetMapping(path = "/metrics", produces = MediaType.TEXT_PLAIN_VALUE)
    public void healthz(HttpServletResponse response) throws URISyntaxException {
        RestTemplate restTemplate = new RestTemplate();
        StringBuilder prometheusUrl = new StringBuilder("http://127.0.0.1:");
        prometheusUrl.append(port);
        prometheusUrl.append(contextPath);
        prometheusUrl.append("/actuator/prometheus");

        ResponseEntity<String> responseEntity = restTemplate.getForEntity(prometheusUrl.toString(), String.class);
        String body = responseEntity.getBody();
        String s = JSON.parseObject(body, String.class);

        try (BufferedOutputStream bos = new BufferedOutputStream(response.getOutputStream())) {
            bos.write(s.getBytes());
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
}

```
