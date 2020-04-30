### druid连接池报错：sql injection violation, multi-statement not allow
需要配置druid的 multi-statement-allow属性为true，但是在boot的配置文件里配置了也没有生效，只能改用@bean的方式重新配置datasource
```java
package com.epoch.boot;

import com.alibaba.druid.filter.Filter;
import com.alibaba.druid.filter.stat.StatFilter;
import com.alibaba.druid.pool.DruidDataSource;
import com.alibaba.druid.wall.WallConfig;
import com.alibaba.druid.wall.WallFilter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;
import java.util.ArrayList;
import java.util.List;

/**
 * @author liujy
 * @date 2020/4/27 17:36
 **/
@Configuration
public class DruidConfig {
    //使用连接池dataSource
    @Primary
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.druid")
    public DataSource druidDataSource() {
        DruidDataSource druidDataSource = new DruidDataSource();
        List<Filter> filterList = new ArrayList<>();
        filterList.add(wallFilter());
        filterList.add(statFilter());
        druidDataSource.setProxyFilters(filterList);
        return druidDataSource;

    }
    @Bean
    public WallFilter wallFilter() {
        WallFilter wallFilter = new WallFilter();
        wallFilter.setConfig(wallConfig());
        return wallFilter;
    }

    @Bean
    public StatFilter statFilter(){
        StatFilter statFilter = new StatFilter();
        return statFilter;
    }

    @Bean
    public WallConfig wallConfig() {
        WallConfig config = new WallConfig();
        config.setMultiStatementAllow(true);//允许一次执行多条语句
        return config;
    }

}
```
数据库配置信息
```yml
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    druid:
      driver-class-name: com.mysql.cj.jdbc.Driver
      url: jdbc:mysql://localhost:3306/console?useUnicode=true&characterEncoding=utf-8&useSSL=false&allowMultiQueries=true
      username: root
      password: root
      connection-properties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000
      filters: stat,wall,log4j2
      initial-size: 10
      log-abandoned: true
      max-active: 200
      max-pool-prepared-statement-per-connection-size: 20
      max-wait: 6000
      min-evictable-idle-time-millis: 300000
      min-idle: 5
      pool-prepared-statements: true
      remove-abandoned: true
      remove-abandoned-timeout: 1800
      test-on-borrow: false
      test-on-return: false
      test-while-idle: true
      time-between-eviction-runs-millis: 60000
      validation-query: SELECT 1 FROM DUAL
```
注意：此处jdbc的url要添加字符串`&allowMultiQueries=true`
