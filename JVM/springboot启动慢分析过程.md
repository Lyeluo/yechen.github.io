JVM参数设置
```bash
-Xmx2048m -Xms2048m -Xmn768m -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M
```
### 1. 生成GC日志并网站在线分析
1. 生成gc日志命令
```bash
-Xloggc:./gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps
```
2. 在线分析网站
    https://gceasy.io/
3. 调整过程：  
根据GC日志分析得到年轻代GC频繁，没有老年代GC；  
调整年轻代大小为堆的1/2，性能并没有优化，反而有了更多消耗时间更长的GC  
#### 结论：
工程启动慢与年轻代GC频繁无关

### 2. 生成dump文件分析
1. 生产dump文件命令
```bash
jmap -dump:format=b,file=./heap.hprof  进程号
```
结果：没有发现有个别大对象占用大量内存的情况
### 3.分析日志
```
[2021-09-03 10:42:58.668] - [INFO] - [main] - [org.springframework.aop.framework.CglibAopProxy] - Unable to proxy interface-implementing method [public final java.util.List com.epoch.bdp.util.service.excel.AbstractExcelProcess.getExcelHeader(com.epoch.bdp.util.service.excel.context.ExcelProcessContext)] because it is marked as final: Consider using interface-based JDK proxies instead! 

```
结论：部分被代理类因为类中有final修饰的方法，无法被cglib进行代理
### 4.JVM启动参数优化
这里主要涉及的启动参数设置是下面两个:  
1. -XX:TieredStopAtLevel=1
使用C1编译器，又称为客户端模式，相对于C2也就是服务端模式，C1编译生成的机器码更加关注快速启动但是由于机器码没有经过编译优化所以不适合在线上环境稳定运行。
2. -Xverify:none/ -noverify
通过去除字节码的验证来提升JVM启动速度，同样不适合线上对安全有要求的环境使用。
结论：这两种方式 都不适用于生产环境，所以并未启用
### 5.springboot 懒加载方案
springboot2.2以后支持配置全局懒加载机制，springboot2.2以前实现BeanFactoryPostProcessor 类。  
但是存在以下问题：  
1. 大部分对象启动时未初始化，不好估算应用使用内存
2. 启动时不加载部分类，如果有错误不会抛出，不容易发现问题
3. 第一次请求是时间会很慢，后续请求不会有此问题
结论：考虑到上面的影响，以及测试过程中发现很多对象配置为懒加载会影响项目启动，所以未采用
### 6.判断类的加载时间

```java
package com.epoch.boot.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.stereotype.Component;

import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 〈一句话功能简述〉
 *
 * @author 刘建宇
 * @since ECS2.0
 */
@Component
public class BeanInitCostTimeBeanPostProcessor implements BeanPostProcessor {

    private static final Logger logger = LoggerFactory.getLogger(BeanInitCostTimeBeanPostProcessor.class);

    private static final ConcurrentHashMap<String, Long> START_TIME = new ConcurrentHashMap<>();

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        START_TIME.put(beanName, System.currentTimeMillis());
        return bean;
    }
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
     if(Objects.nonNull(START_TIME.get(beanName))){
         long costTime = System.currentTimeMillis() - START_TIME.get(beanName);
          if(costTime>300) {
              logger.error("beanName:{},cost:{}",beanName,costTime);
          }
     }
        START_TIME.clear();
        return bean;
    }
}
```
结论：发现有个别对象初始化时占用时间较长
### 7. 分析aop
注解说明
```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import({AspectJAutoProxyRegistrar.class})
public @interface EnableAspectJAutoProxy {
    // true：使用cglib代理，false：使用jdk代理
    boolean proxyTargetClass() default false;
    // 控制代理的暴露方式,解决内部调用不能使用代理的场景，默认为false.
    boolean exposeProxy() default false;
}
```
最后判断结果为：因为项目中配置了大量AOP切面类，严重影响了启动速度
