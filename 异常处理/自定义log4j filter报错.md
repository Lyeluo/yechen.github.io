##报错Unable to invoke factory method in class com.yuanian.mbase.config.log4j.ScheduleLoggerFilter
```
2020-05-13 16:32:35,613 main ERROR Unable to invoke factory method in class com.yuanian.mbase.config.log4j.ScheduleLoggerFilter for element ScheduleLoggerFilter: java.lang.IllegalStateException: No factory method found for class com.yuanian.mbase.config.log4j.ScheduleLoggerFilter java.lang.IllegalStateException: No factory method found for class com.yuanian.mbase.config.log4j.ScheduleLoggerFilter
	at org.apache.logging.log4j.core.config.plugins.util.PluginBuilder.findFactoryMethod(PluginBuilder.java:234)
	at org.apache.logging.log4j.core.config.plugins.util.PluginBuilder.build(PluginBuilder.java:134)
	at org.apache.logging.log4j.core.config.AbstractConfiguration.createPluginObject(AbstractConfiguration.java:964)
	at org.apache.logging.log4j.core.config.AbstractConfiguration.createConfiguration(AbstractConfiguration.java:904)
	at org.apache.logging.log4j.core.config.AbstractConfiguration.createConfiguration(AbstractConfiguration.java:896)
	at org.apache.logging.log4j.core.config.AbstractConfiguration.createConfiguration(AbstractConfiguration.java:896)
	at org.apache.logging.log4j.core.config.AbstractConfiguration.createConfiguration(AbstractConfiguration.java:896)
	at org.apache.logging.log4j.core.config.AbstractConfiguration.doConfigure(AbstractConfiguration.java:514)
	at org.apache.logging.log4j.core.config.AbstractConfiguration.initialize(AbstractConfiguration.java:238)
	at org.apache.logging.log4j.core.config.AbstractConfiguration.start(AbstractConfiguration.java:250)
	at org.apache.logging.log4j.core.LoggerContext.setConfiguration(LoggerContext.java:548)
	at org.apache.logging.log4j.core.LoggerContext.reconfigure(LoggerContext.java:620)
	at org.apache.logging.log4j.core.LoggerContext.reconfigure(LoggerContext.java:637)
	at org.springframework.boot.logging.log4j2.Log4J2LoggingSystem.reinitialize(Log4J2LoggingSystem.java:194)
	at org.springframework.boot.logging.AbstractLoggingSystem.initializeWithConventions(AbstractLoggingSystem.java:75)
	at org.springframework.boot.logging.AbstractLoggingSystem.initialize(AbstractLoggingSystem.java:60)
	at org.springframework.boot.logging.log4j2.Log4J2LoggingSystem.initialize(Log4J2LoggingSystem.java:148)
	at org.springframework.cloud.bootstrap.config.PropertySourceBootstrapConfiguration.reinitializeLoggingSystem(PropertySourceBootstrapConfiguration.java:136)
	at org.springframework.cloud.bootstrap.config.PropertySourceBootstrapConfiguration.initialize(PropertySourceBootstrapConfiguration.java:113)
	at org.springframework.boot.SpringApplication.applyInitializers(SpringApplication.java:649)
	at org.springframework.boot.SpringApplication.prepareContext(SpringApplication.java:373)
	at org.springframework.boot.SpringApplication.run(SpringApplication.java:314)
	at org.springframework.boot.SpringApplication.run(SpringApplication.java:1260)
	at org.springframework.boot.SpringApplication.run(SpringApplication.java:1248)
	at com.yuanian.mbase.App.main(App.java:14)
```
原因：没有加工厂创建方法，即注解标注@PluginFactory的这个方法，必须提供  
完整代码如下：
```java
package com.***.**.*.log4j;


import com.xxl.job.core.log.XxlJobFileAppender;
import com.xxl.job.core.log.XxlJobLogger;
import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.Marker;
import org.apache.logging.log4j.core.Filter;
import org.apache.logging.log4j.core.LogEvent;
import org.apache.logging.log4j.core.Logger;
import org.apache.logging.log4j.core.config.Node;
import org.apache.logging.log4j.core.config.plugins.Plugin;
import org.apache.logging.log4j.core.config.plugins.PluginAttribute;
import org.apache.logging.log4j.core.config.plugins.PluginFactory;
import org.apache.logging.log4j.core.filter.AbstractFilter;
import org.apache.logging.log4j.message.Message;
import org.apache.logging.log4j.util.PerformanceSensitive;

/**
 * @author liujy
 * @date 2020/5/13 9:55
 * 替换控制台原收集日志filter，增加调度中心rolling收集业务日志的功能
 **/
@Plugin(name = "ScheduleLoggerFilter", category = Node.CATEGORY, elementType = Filter.ELEMENT_TYPE, printObject = true)
@PerformanceSensitive({"allocation"})
public class ScheduleLoggerFilter extends AbstractFilter {

    private final Level level;

    @PluginFactory
    public static ScheduleLoggerFilter createFilter(@PluginAttribute("level") Level level, @PluginAttribute("onMatch") Result match, @PluginAttribute("onMismatch") Result mismatch) {
        Level actualLevel = level == null ? Level.ERROR : level;
        Result onMatch = match == null ? Result.NEUTRAL : match;
        Result onMismatch = mismatch == null ? Result.DENY : mismatch;
        return new ScheduleLoggerFilter(actualLevel, onMatch, onMismatch);
    }

    private ScheduleLoggerFilter(Level level, Result onMatch, Result onMismatch) {
        super(onMatch, onMismatch);
        this.level = level;
    }

    @Override
    public Result filter(LogEvent event) {
        String logFileName = XxlJobFileAppender.contextHolder.get();
        if (logFileName != null && logFileName.trim().length() > 0) {
            Message message = event.getMessage();
            String formattedMessage = message.getFormattedMessage();
            XxlJobLogger.log(formattedMessage);
        }
        return super.filter(event);
    }

    @Override
    public Result filter(Logger logger, Level testLevel, Marker marker, String msg, Object... params) {
        return this.filter(testLevel);
    }

    @Override
    public Result filter(Logger logger, Level testLevel, Marker marker, Object msg, Throwable t) {
        return this.filter(testLevel);
    }

    @Override
    public Result filter(Logger logger, Level testLevel, Marker marker, Message msg, Throwable t) {
        return this.filter(testLevel);
    }

    private Result filter(Level testLevel) {
        return testLevel.isMoreSpecificThan(this.level) ? this.onMatch : this.onMismatch;
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1, Object p2) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1, Object p2, Object p3) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1, Object p2, Object p3, Object p4) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1, Object p2, Object p3, Object p4, Object p5) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1, Object p2, Object p3, Object p4, Object p5, Object p6) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1, Object p2, Object p3, Object p4, Object p5, Object p6, Object p7) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1, Object p2, Object p3, Object p4, Object p5, Object p6, Object p7, Object p8) {
        return this.filter(level);
    }

    @Override
    public Result filter(Logger logger, Level level, Marker marker, String msg, Object p0, Object p1, Object p2, Object p3, Object p4, Object p5, Object p6, Object p7, Object p8, Object p9) {
        return this.filter(level);
    }

    public Level getLevel() {
        return this.level;
    }


}
```
配置文件
```yaml
Configuration:
  status: warn
  packages: com.***.**.*.log4j
  monitorInterval: 30
  strict: true
  Appenders:
    Console:  #输出到控制台
      name: CONSOLE
      target: SYSTEM_OUT
      filters:
        ScheduleLoggerFilter:
          level: info
          onMatch: ACCEPT
          onMismatch: DENY
```
---
注意：  
- Console这个appender下的只有第一个filter会生效
- 需要配置扫描路径Configuration.packages，不然扫描不到配置类
