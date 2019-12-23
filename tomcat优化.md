1.随机数生成器耗时高问题
```
打开$JAVA_PATH/jre/lib/security/java.security这个文件
securerandom.source=file:/dev/urandom替换成securerandom.source=file:/dev/./urandom
```
2.TLDS扫描导致启动慢
```
/data/apache-tomcat-8.0.28/conf/catalina.properties
tomcat.util.scan.StandardJarScanFilter.jarsToSkip=\*.jar 忽略全部扫描
```
