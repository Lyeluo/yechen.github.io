报错
```
Exception in thread "main" java.lang.StackOverflowError
at java.base/java.lang.String.equals(String.java:1020)
at org.apache.logging.log4j.util.StackLocator.lambda$getCallerClass$1(StackLocator.java:48)
at java.base/java.util.stream.WhileOps$1Op$1OpSink.accept(WhileOps.java:376)
at java.base/java.util.stream.WhileOps$1Op$1OpSink.accept(WhileOps.java:386)
at java.base/java.lang.StackStreamFactory$StackFrameTraverser.tryAdvance(StackStreamFactory.java:595)
at java.base/java.util.stream.ReferencePipeline.forEachWithCancel(ReferencePipeline.java:127)
at java.base/java.util.stream.AbstractPipeline.copyIntoWithCancel(AbstractPipeline.java:502)
at java.base/java.util.stream.AbstractPipeline.copyInto(AbstractPipeline.java:488)
at java.base/java.util.stream.AbstractPipeline.wrapAndCopyInto(AbstractPipeline.java:474)
at java.base/java.util.stream.FindOps$FindOp.evaluateSequential(FindOps.java:152)
at java.base/java.util.stream.AbstractPipeline.evaluate(AbstractPipeline.java:234)
at java.base/java.util.stream.ReferencePipeline.findFirst(ReferencePipeline.java:476)
at org.apache.logging.log4j.util.StackLocator.lambda$getCallerClass$3(StackLocator.java:49)
at java.base/java.lang.StackStreamFactory$StackFrameTraverser.consumeFrames(StackStreamFactory.java:534)
at java.base/java.lang.StackStreamFactory$AbstractStackWalker.doStackWalk(StackStreamFactory.java:306)
at java.base/java.lang.StackStreamFactory$AbstractStackWalker.callStackWalk(Native Method)
at java.base/java.lang.StackStreamFactory$AbstractStackWalker.beginStackWalk(StackStreamFactory.java:370)
at java.base/java.lang.StackStreamFactory$AbstractStackWalker.walk(StackStreamFactory.java:243)
at java.base/java.lang.StackWalker.walk(StackWalker.java:453)
at org.apache.logging.log4j.util.StackLocator.getCallerClass(StackLocator.java:47)
at org.apache.logging.log4j.util.StackLocatorUtil.getCallerClass(StackLocatorUtil.java:55)
at org.apache.logging.slf4j.Log4jLoggerFactory.getContext(Log4jLoggerFactory.java:42)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:46)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
at org.apache.logging.slf4j.SLF4JLoggerContext.getLogger(SLF4JLoggerContext.java:39)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:37)
at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:29)
at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:52)
at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:29)
at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:358)
```

因为SpringBoot的logging与log4j有冲突,所以需要制定忽略其中一个,这里忽略了SpringBoot自带的
```xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <exclusions><!-- 去掉默认配置 -->
            <exclusion>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-logging</artifactId>
            </exclusion>
        </exclusions>
    </dependency>
```
