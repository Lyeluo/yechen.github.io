```yaml
redis:
    host: 127.0.0.1
    port: 6379
    database: 2
    jedis:
      pool:
      # 最大空闲连接数
        max-idle: 100
      # 最小空闲连接数
        min-idle: 1
        # 连接池最大连接数
        max-active: 1000
        # 连接redis时的最大等待毫秒数。
        max-wait: -1
        # 向资源池借用连接时是否做连接有效性检测(ping)，无效连接会被移除
        # 业务量很大时候建议设置为false(多一次ping的开销)。
        testOnBorrow: false
        # 向资源池归还连接时是否做连接有效性检测(ping)，无效连接会被移除
        # 业务量很大时候建议设置为false(多一次ping的开销)。
        testOnReturn: false
    timeout: 3000
```
参考地址：https://tech.antfin.com/docs/2/98726#section-m2c-5kr-zfb
