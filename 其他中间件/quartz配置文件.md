```properties
#调度标识名 集群中每一个实例都必须使用相同的名称
org.quartz.scheduler.instanceName = quartzScheduler
#调度器实例编号自动生成，每个实例不能不能相同
org.quartz.scheduler.instanceId = AUTO
#开启分布式部署，集群
org.quartz.jobStore.isClustered = true
#分布式节点有效性检查时间间隔，单位：毫秒,默认值是15000
org.quartz.jobStore.clusterCheckinInterval = 2000
#远程管理相关的配置,全部关闭
org.quartz.scheduler.rmi.export: false
org.quartz.scheduler.rmi.proxy: false
org.quartz.scheduler.wrapJobExecutionInUserTransaction: false
#实例化ThreadPool时，使用的线程类为SimpleThreadPool（一般使用SimpleThreadPool即可满足几乎所有用户的需求）
org.quartz.threadPool.class = org.quartz.simpl.SimpleThreadPool
##并发个数,指定线程数，至少为1（无默认值）(一般设置为1-100之间的的整数合适)
org.quartz.threadPool.threadCount = 10
##设置线程的优先级（最大为java.lang.Thread.MAX_PRIORITY 10，最小为Thread.MIN_PRIORITY 1，默认为5）
org.quartz.threadPool.threadPriority = 5
#org.quartz.threadPool.threadsInheritContextClassLoaderOfInitializingThread = true
#容许的最大作业延长时间,最大能忍受的触发超时时间，如果超过则认为“失误”,不敢再内存中还是数据中都要配置
org.quartz.jobStore.misfireThreshold = 6000
#持久化方式配置
# 默认存储在内存中，保存job和Trigger的状态信息到内存中的类
#org.quartz.jobStore.class = org.quartz.simpl.RAMJobStore
#数据库方式
org.quartz.jobStore.class = org.quartz.impl.jdbcjobstore.JobStoreTX
#持久化方式配置数据驱动，MySQL数据库
org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.StdJDBCDelegate
#quartz相关数据表前缀名
org.quartz.jobStore.tablePrefix = QRTZ_
 
#数据库别名 随便取
#org.quartz.jobStore.dataSource = qzDS
#org.quartz.dataSource.qzDS.driver = com.mysql.jdbc.Driver
#org.quartz.dataSource.qzDS.URL = jdbc:mysql://192.168.184.135:3306/quartzdb?useSSL=false&useUnicode=true&characterEncoding=UTF-8
#org.quartz.dataSource.qzDS.user = root
#org.quartz.dataSource.qzDS.password = 123456
#org.quartz.dataSource.qzDS.maxConnections = 10
#org.quartz.dataSource.qzDS.acquireIncrement=1
```
