## 配置proxySql
```properties
spring.datasource.url=jdbc:mysql://${DB_URL:192.168.61.22:6033,192.168.61.21:6033,192.168.61.23:6033}/${DB_SCHEMA:xxl-job}?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai
```
