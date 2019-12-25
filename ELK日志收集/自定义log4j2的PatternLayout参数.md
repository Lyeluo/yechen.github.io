1.添加类
```java
package com.yuanian.micro.config;

import org.apache.logging.log4j.core.LogEvent;
import org.apache.logging.log4j.core.config.plugins.Plugin;
import org.apache.logging.log4j.core.pattern.ConverterKeys;
import org.apache.logging.log4j.core.pattern.LogEventPatternConverter;
import org.apache.logging.log4j.core.pattern.PatternConverter;

/**
 * @author liujy
 * @date 2019/12/18 16:46
 * 增加serviceName到日志的pattern
 **/
@Plugin(name = "ServiceNamePatternConverter", category = PatternConverter.CATEGORY)
@ConverterKeys({"s", "serviceName"})
public class ServiceNamePatternConverter extends LogEventPatternConverter {
    private  String SERVICENAME = "ms-job-console";

    private static final ServiceNamePatternConverter INSTANCE =
            new ServiceNamePatternConverter();

    public static ServiceNamePatternConverter newInstance(
            final String[] options) {
        return INSTANCE;
    }

    private ServiceNamePatternConverter() {
        super("serviceName", "serviceName");
    }

    @Override
    public void format(LogEvent logEvent, StringBuilder toAppendTo) {
        toAppendTo.append(SERVICENAME);
    }
}
```
2. 修改log4j2.yml文件，添加变量Configuration.packages为刚才创建类所在的包
```yaml
Configuration:
  status: warn
  packages: com.yuanian.micro.config
```
3.在log4j2.yml中使用自定义的参数
```yaml
Configuration:
  status: warn
  packages: com.yuanian.micro.config
  Appenders:
    Console:  #输出到控制台
      name: CONSOLE
      target: SYSTEM_OUT
      ThresholdFilter:
        level: info
        onMatch: ACCEPT
        onMismatch: DENY
      PatternLayout:
        pattern: "%d %p %c [serviceName = %s] [Class = %c] [File = %F] [Line = %L] [Method = %M] [%t] %m%n"
```
4.效果如下:
```
2019-12-18 17:24:00,183 WARN com.alibaba.cloud.nacos.client.NacosPropertySourceBuilder [serviceName = ms-job-console] [Class = com.alibaba.cloud.nacos.client.NacosPropertySourceBuilder] [File = NacosPropertySourceBuilder.java] [Line = 86] [Method = loadNacosData] [main] Ignore the empty nacos configuration and get it based on dataId[ms-job-console] & group[DEFAULT_GROUP]
```
5.不可以把参数定义重复，log4j2自定义的参数可以参考下面的地址 https://blog.csdn.net/guoquanyou/article/details/5689652  

---  
本文参考链接：https://www.cnblogs.com/zr520/p/6406443.html
