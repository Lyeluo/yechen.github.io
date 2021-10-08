| 类别             | 函数          | 入参           | 说明                                                         |
| ---------------- | ------------- | -------------- | ------------------------------------------------------------ |
| 方法切点函数     | execution()   | 方法匹配模式串 | 表示满足某一匹配模式的所有目标类方法连接点。如execution(* greetTo(..))表示所有目标类中的greetTo()方法。 |
|                  | @annotation() | 方法注解类名   | 表示标注了特定注解的目标方法连接点。如@annotation(com.baobaotao.anno.NeedTest)表示任何标注了@NeedTest注解的目标类方法。 |
| 方法入参切点函数 | args()        | 类名           | 通过判别目标类方法运行时入参对象的类型定义指定连接点。如args(com.baobaotao.Waiter)表示所有有且仅有一个按类型匹配于Waiter的入参的方法。 |
|                  | @args()       | 类型注解类名   | 通过判别目标方法的运行时入参对象的类是否标注特定注解来指定连接点。如@args(com.baobaotao.Monitorable)表示任何这样的一个目标方法：它有一个入参且入参对象的类标注@Monitorable注解。 |
| 目标类切点函数   | within()      | 类名匹配串     | 表示特定域下的所有连接点。如within(com.baobaotao.service.*)表示com.baobaotao.service包中的所有连接点，也即包中所有类的所有方法，而within(com.baobaotao.service.*Service)表示在com.baobaotao.service包中，所有以Service结尾的类的所有连接点。 |
|                  | target()      | 类名           | 假如目标类按类型匹配于指定类，则目标类的所有连接点匹配这个切点。如通过target(com.baobaotao.Waiter)定义的切点，Waiter、以及Waiter实现类NaiveWaiter中所有连接点都匹配该切点。 |
|                  | @within()     | 类型注解类名   | 假如目标类按类型匹配于某个类A，且类A标注了特定注解，则目标类的所有连接点匹配这个切点。  如@within(com.baobaotao.Monitorable)定义的切点，假如Waiter类标注了@Monitorable注解，则Waiter以及Waiter实现类NaiveWaiter类的所有连接点都匹配。 |
|                  | @target()     | 类型注解类名   | 目标类标注了特定注解，则目标类所有连接点匹配该切点。如@target(com.baobaotao.Monitorable)，假如NaiveWaiter标注了@Monitorable，则NaiveWaiter所有连接点匹配切点。 |
| 代理类切点函数   | this()        | 类名           | 代理类按类型匹配于指定类，则被代理的目标类所有连接点匹配切点。这个函数比较难理解，这里暂不举例，留待后面详解。 |
