```properties
#���ȱ�ʶ�� ��Ⱥ��ÿһ��ʵ��������ʹ����ͬ������
org.quartz.scheduler.instanceName = quartzScheduler
#������ʵ������Զ����ɣ�ÿ��ʵ�����ܲ�����ͬ
org.quartz.scheduler.instanceId = AUTO
#�����ֲ�ʽ���𣬼�Ⱥ
org.quartz.jobStore.isClustered = true
#�ֲ�ʽ�ڵ���Ч�Լ��ʱ��������λ������,Ĭ��ֵ��15000
org.quartz.jobStore.clusterCheckinInterval = 2000
#Զ�̹�����ص�����,ȫ���ر�
org.quartz.scheduler.rmi.export: false
org.quartz.scheduler.rmi.proxy: false
org.quartz.scheduler.wrapJobExecutionInUserTransaction: false
#ʵ����ThreadPoolʱ��ʹ�õ��߳���ΪSimpleThreadPool��һ��ʹ��SimpleThreadPool�������㼸�������û�������
org.quartz.threadPool.class = org.quartz.simpl.SimpleThreadPool
##��������,ָ���߳���������Ϊ1����Ĭ��ֵ��(һ������Ϊ1-100֮��ĵ���������)
org.quartz.threadPool.threadCount = 10
##�����̵߳����ȼ������Ϊjava.lang.Thread.MAX_PRIORITY 10����СΪThread.MIN_PRIORITY 1��Ĭ��Ϊ5��
org.quartz.threadPool.threadPriority = 5
#org.quartz.threadPool.threadsInheritContextClassLoaderOfInitializingThread = true
#����������ҵ�ӳ�ʱ��,��������ܵĴ�����ʱʱ�䣬�����������Ϊ��ʧ��,�������ڴ��л��������ж�Ҫ����
org.quartz.jobStore.misfireThreshold = 6000
#�־û���ʽ����
# Ĭ�ϴ洢���ڴ��У�����job��Trigger��״̬��Ϣ���ڴ��е���
#org.quartz.jobStore.class = org.quartz.simpl.RAMJobStore
#���ݿⷽʽ
org.quartz.jobStore.class = org.quartz.impl.jdbcjobstore.JobStoreTX
#�־û���ʽ��������������MySQL���ݿ�
org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.StdJDBCDelegate
#quartz������ݱ�ǰ׺��
org.quartz.jobStore.tablePrefix = QRTZ_
 
#���ݿ���� ���ȡ
#org.quartz.jobStore.dataSource = qzDS
#org.quartz.dataSource.qzDS.driver = com.mysql.jdbc.Driver
#org.quartz.dataSource.qzDS.URL = jdbc:mysql://192.168.184.135:3306/quartzdb?useSSL=false&useUnicode=true&characterEncoding=UTF-8
#org.quartz.dataSource.qzDS.user = root
#org.quartz.dataSource.qzDS.password = 123456
#org.quartz.dataSource.qzDS.maxConnections = 10
#org.quartz.dataSource.qzDS.acquireIncrement=1
```
