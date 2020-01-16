## Statefulset
Statefulset与ReplicaSet/ReplicationController的区别：
+ ReplicaSet/ReplicationController就好比牧场中的牛，死掉一个然后补上一个，牧场主不会发觉有什么改变。
+ Statefulset就好比宠物，死掉一个，然后很难找到完全相似的宠物，但是Statefulset可以创建一个完全一样的宠物出来。
+ Statefulset创建的每一个pod有独立的数据卷，而且Statefulset创建的pod有固定的名称，是根据pod顺序定义的，即使挂掉重建后名称仍然不会变。
![Statefulset的pod名称固定](../images/1579145402(1).jpg) 

这里面宠物对应的就是kubernetes中的pod。
##### 在kubernetes集群内部通过域名访问pod
一个default命名空间中的Statefulset的一个pod，名为podA-0，service服务名为foo，那么他的域名为：podA-0.foo.default.svc.cluster.local  
