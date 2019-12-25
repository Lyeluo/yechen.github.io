1.需要添加依赖
```xml
        <!-- log4j2 kafka appender -->
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>0.9.0.1</version>
            <exclusions> <!-- exclude掉过时的log依赖 -->
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
                <exclusion>
                    <groupId>log4j</groupId>
                    <artifactId>log4j</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <!-- 加上这个才能辨认到log4j2.yml文件 -->
        <dependency>
            <groupId>com.fasterxml.jackson.dataformat</groupId>
            <artifactId>jackson-dataformat-yaml</artifactId>
        </dependency>
```
2.添加配置文件
```yaml
Configuration:
  status: warn
  packages: com.yuanian.micro.config
  monitorInterval: 30
  strict: true

  Appenders:
    Console:  #输出到控制台
      filter: ThresholdFilter
      name: CONSOLE
      target: SYSTEM_OUT
      ThresholdFilter:
        level: info
        onMatch: ACCEPT
        onMismatch: DENY
      PatternLayout:
        pattern: "%d %p %s %h [Class = %c] [File = %F] [Line = %L] [Method = %M] [%t] %m%n"
    Kafka: #输出到Kafka
      name: KAFKA
      topic:  log4j
      # 目前还没有广泛使用，默认为true，设置为false可以发送消息后立即返回，减少延迟，但是消息可能会丢失，也有可能导致消息顺序错乱
      syncSend: true 
      ThresholdFilter:
        level: info
        onMatch: ACCEPT
        onMismatch: DENY
      PatternLayout:
        pattern: "%d %p %s %h [Class = %c] [File = %F] [Line = %L] [Method = %M] [%t] %m%n"
      Property:
        - name: bootstrap.servers
          value: 192.168.2.183:9092,192.168.2.184:9092,192.168.2.185:9092

  Loggers:
    Root:
      level: info
      AppenderRef:
        - ref: CONSOLE
        - ref: KAFKA
    Logger: # 为com.yuanian包配置特殊的Log级别，方便调试
      - name: com.yuanian
        additivity: false
        level: trace
        AppenderRef:
          - ref: CONSOLE
          - ref: KAFKA
      - name: org.apache.kafka #听说这样可以避免递归调用
        level: INFO


```
