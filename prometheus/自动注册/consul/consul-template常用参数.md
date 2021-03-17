#常用参数的作用：
- consul-auth=<username[:password]>     # 设置基本的认证用户名和密码。
- consul-addr=<address>                 # 设置Consul实例的地址。
- max-stale=<duration>                  # 查询过期的最大频率，默认是1s。
- dedup                                 # 启用重复数据删除，当许多consul template实例渲染一个模板的时候可以降低consul的负载。
- consul-ssl                            # 使用https连接Consul。
- consul-ssl-verify                     # 通过SSL连接的时候检查证书。
- consul-ssl-cert                       # SSL客户端证书发送给服务器。
- consul-ssl-key                        # 客户端认证时使用的SSL/TLS私钥。
- consul-ssl-ca-cert                    # 验证服务器的CA证书列表。
- consul-token=<token>                  # 设置Consul API的token。
- syslog                                # 把标准输出和标准错误重定向到syslog，syslog的默认级别是local0。
- syslog-facility=<facility>            # 设置syslog级别，默认是local0，必须和-syslog配合使用。
- template=<template>                   # 增加一个需要监控的模板，格式是：'templatePath:outputPath(:command)'，多个模板则可以设置多次。
- wait=<duration>                       # 当呈现一个新的模板到系统和触发一个命令的时候，等待的最大最小时间。如果最大值被忽略，默认是最小值的4倍。
- retry=<duration>                      # 当在和consul api交互的返回值是error的时候，等待的时间，默认是5s。
- config=<path>                         # 配置文件或者配置目录的路径。
- pid-file=<path>                       # PID文件的路径。
- log-level=<level>                     # 设置日志级别，可以是"debug","info", "warn" (default), and "err"。
- dry                                   # Dump生成的模板到标准输出，不会生成到磁盘。
- once 

作者：青牛踏雪御苍穹
链接：https://juejin.cn/post/6869570557608722446
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
