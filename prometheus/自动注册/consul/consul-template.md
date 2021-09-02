# Consul Template 简介

Consul Template 提供一个方便的方式从Consul获取数据通过consul-template的后台程序保存到文件系统.

这个后台进程监控Consul示例的变化并更新任意数量的模板到文件系统.作为一个附件功能,模板更新完成后consul-template可以运行任何命令.可以查看示例部分看这个功能将会对哪些应用场景产生帮助.

## 安装

你可以在[发布页](https://releases.hashicorp.com/consul-template/)下载发布包.如果你希望自己编译请查看[说明文档](https://github.com/hashicorp/consul-template#contributing).

## 使用

#### 选项

查看全部选项,使用以下命令

```
consul-template -h
```

#### 命令行

`CLI` 接口支持上面出现的所有选项.

查询 `demo.consul.io` 这个 `Consul` 实例(agent).渲染模板文件 `/tmp/template.ctmpl` 保存到 `/tmp/result`, 运行`Consul-template` 服务直到直到手动结束:

```shss
consul-template \
  -consul demo.consul.io \
  -template "/tmp/template.ctmpl:/tmp/result"
```

查询本地的`Consul` 实例(agent),一旦模板发生变化渲染模板并重启 `Nginx` ,如果 `Consul` 不可用30秒重试一次:

```sh
consul-template \
  -consul 127.0.0.1:8500 \
  -template "/tmp/template.ctmpl:/var/www/nginx.conf:service nginx restart" \
  -retry 30s \
  -once
```

查询一个`Consul`实例,渲染多个模板并作为服务直到停止:

```
consul-template \
  -consul my.consul.internal:6124 \
  -template "/tmp/nginx.ctmpl:/var/nginx/nginx.conf:service nginx restart" \
  -template "/tmp/redis.ctmpl:/var/redis/redis.conf:service redis restart" \
  -template "/tmp/haproxy.ctmpl:/var/haproxy/haproxy.conf"
```

查询一个需要权限验证的 `Consul` 实例,将渲染后的模板输出到控制台而不写入磁盘.在这个例子中 `-template` 的第二个和第三个参数是必须的但是被忽略了.这个文件将不会被写入磁盘,命令也不会被执行.

```
$ consul-template \
  -consul my.consul.internal:6124 \
  -template "/tmp/template.ctmpl:/tmp/result:service nginx restart"
  -dry
```

使用SSL证书进行`Consul`的查询:

```
$ consul-template \
  -consul 127.0.0.1:8543 \
  -ssl \
  -ssl-cert /path/to/client/cert.pem \
  -ssl-ca-cert /path/to/ca/cert.pem \
  -template "/tmp/template.ctmpl:/tmp/result" \
  -dry \
  -once
```

查询 `Consul` 并启动一个子进程.模板的变化会发送指令给子进程.详细的说明请查看[这里](https://github.com/hashicorp/consul-template#exec-mode).

```
$ consul-template \
  -template "/tmp/in.ctmpl:/tmp/result" \
  -exec "/sbin/my-server"
```

#### 配置文件

`Consul-Template` 配置文件是使用[HashiCorp Configuration Language (HCL)](https://github.com/hashicorp/hcl)编写的.这意味着`Consul Template` 是和JSON兼容的,查看更多信息请查看 [HCL 规范](https://github.com/hashicorp/hcl)

配置文件语法支持上面的所有的选项,除非在表格中进行标明.

```json
// 这是要连接的Consul Agent的地址.默认为127.0.0.1:8500.这是Consul的默认绑定地址和端口.
// 不建议你直接与 Consul的 Server直接进行交互,请与本地的Consul Agent进行交互.这样做是有一些原因
// 最重要的是本地agent可以复用与server的连接.减少HTTP的连接数.另外这个地址更好记.
consul = "127.0.0.1:8500"

// 这是用于连接Consul的ACL token. 如果你的集群未启用就不需要设置.
//
// 这个选项也可以通过环境变量 CONSUL_TOKEN 来进行设置
token = "abcd1234"

// 这是监听出发reload事件的信号,默认值如下所示.将这个值设置为空将引起 CT ,从而不监听reload事件
reload_signal = "SIGHUP"

// 这是监听出发core dump事件的信号,默认值如下所示.将这个值设置为空将引起 CT ,从而不监听core dump信号
dump_signal = "SIGQUIT"

// 这是监听出发graceful stop事件的信号,默认值如下所示.将这个值设置为空将引起 CT ,从而不监听graceful stop信号
kill_signal = "SIGINT"

// 这是连接Consul的重试时间.Consul Template是高容错的设计.这意味着,出现失败他不会退出.而按照
// 分布式系统的惯例进行指数补偿和重试来等待集群恢复.
retry = "10s"

// This is the maximum interval to allow "stale" data. By default, only the
// Consul leader will respond to queries; any requests to a follower will
// forward to the leader. In large clusters with many requests, this is not as
// scalable, so this option allows any follower to respond to a query, so long
// as the last-replicated data is within these bounds. Higher values result in
// less cluster load, but are more likely to have outdated data.
// 这是允许陈旧数据的最大时间.Consul默认只有领袖对请求进行相应.所有对追随者的请求将被转发给领袖.
// 在有大量请求的大型集群中,这显得不够有扩展性.所以这个选项允许任何追随者响应查询,只要最后复制的数据
// 在这个范围内.数值越高,越减少集群负载,但是更容易接受到过期数据.
max_stale = "10m"

// 这是log的等级,如果你找到了bug,请打开debug 日志,这样我们可以更好的定位问题.这个选项也可用在命令行.
log_level = "warn"

// 这是存放Consul Template 进程的PID文件的路径,如果你计划发送定制的信号到这个进程这会比较有用.
pid_file = "/path/to/pid"

// 这是一个静止定时器,他定义了在模板渲染之前等待集群达到一致状态的最小和最大时间.
// 这对于一些变化较大的系统中比较有用,可以减少模板渲染的次数
wait = "5s:10s"


// 这是 Vault配置的开始
// Vault是HashiCorp的另外一个产品
vault {
  // This is the address of the Vault leader. The protocol (http(s)) portion
  // of the address is required.
  address = "https://vault.service.consul:8200"

  // This is the token to use when communicating with the Vault server.
  // Like other tools that integrate with Vault, Consul Template makes the
  // assumption that you provide it with a Vault token; it does not have the
  // incorporated logic to generate tokens via Vault's auth methods.
  //
  // This value can also be specified via the environment variable VAULT_TOKEN.
  token = "abcd1234"

  // This option tells Consul Template to automatically renew the Vault token
  // given. If you are unfamiliar with Vault's architecture, Vault requires
  // tokens be renewed at some regular interval or they will be revoked. Consul
  // Template will automatically renew the token at half the lease duration of
  // the token. The default value is true, but this option can be disabled if
  // you want to renew the Vault token using an out-of-band process.
  //
  // Note that secrets specified in a template (using {{secret}} for example)
  // are always renewed, even if this option is set to false. This option only
  // applies to the top-level Vault token itself.
  renew = true

  // This section details the SSL options for connecting to the Vault server.
  // Please see the SSL options below for more information (they are the same).
  ssl {
    // ...
  }
}

// 这部分配置请求的基本的权限验证信息
auth {
  enabled  = true
  username = "test"
  password = "test"
}

// 这部分配置连接到Consul服务器的SSL信息.
ssl {
  // 使用SSL需要先打开这个开关
  enabled = true

  // This enables SSL peer verification. The default value is "true", which
  // will check the global CA chain to make sure the given certificates are
  // valid. If you are using a self-signed certificate that you have not added
  // to the CA chain, you may want to disable SSL verification. However, please
  // understand this is a potential security vulnerability.
  verify = false

  // This is the path to the certificate to use to authenticate. If just a
  // certificate is provided, it is assumed to contain both the certificate and
  // the key to convert to an X509 certificate. If both the certificate and
  // key are specified, Consul Template will automatically combine them into an
  // X509 certificate for you.
  cert = "/path/to/client/cert"
  key = "/path/to/client/key"

  // This is the path to the certificate authority to use as a CA. This is
  // useful for self-signed certificates or for organizations using their own
  // internal certificate authority.
  ca_cert = "/path/to/ca"
}

// 设置连接到syslog服务器的配置
// 用于进行日志记录syslog {
  // 打开开关
  enabled = true

  // 设备名称
  facility = "LOCAL5"
}

// This block defines the configuration for de-duplication mode. Please see the
// de-duplication mode documentation later in the README for more information
// on how de-duplication mode operates.
deduplicate {
  // This enables de-duplication mode. Specifying any other options also enables
  // de-duplication mode.
  enabled = true

  // This is the prefix to the path in Consul's KV store where de-duplication
  // templates will be pre-rendered and stored.
  prefix = "consul-template/dedup/"
}

// This block defines the configuration for exec mode. Please see the exec mode
// documentation at the bottom of this README for more information on how exec
// mode operates and the caveats of this mode.
exec {
  // This is the command to exec as a child process. There can be only one
  // command per Consul Template process.
  command = "/usr/bin/app"

  // This is a random splay to wait before killing the command. The default
  // value is 0 (no wait), but large clusters should consider setting a splay
  // value to prevent all child processes from reloading at the same time when
  // data changes occur. When this value is set to non-zero, Consul Template
  // will wait a random period of time up to the splay value before reloading
  // or killing the child process. This can be used to prevent the thundering
  // herd problem on applications that do not gracefully reload.
  splay = "5s"

  // This defines the signal that will be sent to the child process when a
  // change occurs in a watched template. The signal will only be sent after
  // the process is started, and the process will only be started after all
  // dependent templates have been rendered at least once. The default value
  // is "" (empty or nil), which tells Consul Template to restart the child
  // process instead of sending it a signal. This is useful for legacy
  // applications or applications that cannot properly reload their
  // configuration without a full reload.
  reload_signal = "SIGUSR1"

  // This defines the signal sent to the child process when Consul Template is
  // gracefully shutting down. The application should begin a graceful cleanup.
  // If the application does not terminate before the `kill_timeout`, it will
  // be terminated (effectively "kill -9"). The default value is "SIGTERM".
  kill_signal = "SIGINT"

  // This defines the amount of time to wait for the child process to gracefully
  // terminate when Consul Template exits. After this specified time, the child
  // process will be force-killed (effectively "kill -9"). The default value is
  // "30s".
  kill_timeout = "2s"
}

// 这部分定义了对模板的配置,和其他配置块不同.这部分可以针对不同模板配置多次.也可以在CLI命令
// 直接进行配置
template {
  // 这是输入模板的配置文件路径,必选项
  source = "/path/on/disk/to/template.ctmpl"

  // 这是源模板渲染之后存放的路径,如果父目录不存在Consul Template会尝试进行创建
  destination = "/path/on/disk/where/template/will/render.txt"

  // This is the optional command to run when the template is rendered. The
  // command will only run if the resulting template changes. The command must
  // return within 30s (configurable), and it must have a successful exit code.
  // Consul Template is not a replacement for a process monitor or init system.
  // 这是当模板渲染完成后可选的要执行的命令.这个命令只会在模板发生改变后才会运行.这个命令必须要在30秒
  // 内进行返回(可配置),必须返回一个成功的退出码.Consul Template不能替代进程监视或者init 系统
  // 的功能
  command = "restart service foo"

  // 这是最大的等待命令返回的时间,默认是30秒
  command_timeout = "60s"

  // 这是渲染后的文件的权限,如果不设置,Consul Template将去匹配之前已经存在的文件的权限.
  // 如果文件不存在,权限会被设置为 0644
  perms = 0600

  // 这个选项对渲染之前的文件进行备份.他保持一个备份.
  // 这个选项在发生意外更高时,有一个回滚策略.
  backup = true

  // 模板的分隔符,默认是 "{{"和"}}".但是对于一些模板用其他的分隔符可能更好
  // 可以避免与本身的冲突
  left_delimiter  = "{{"
  right_delimiter = "}}"

  // 这是最小和最大等待渲染一个新模板和执行命令的时间.使用 分号 个号.如果忽略最大值,最大
  // 值会被设置为最小值的4倍.这个选项没有默认值.这个值相对全局所以的等待时间有最高优先级
  wait = "2s:6s"
}
```

> 注意: 不是所有的选项都是必选的.例如: 如果你没有使用Vault你不用设置这一块. 类似的你没有使用syslog系统你也不需要指定syslog配置.

为了更加安全,`token`也可以从环境变量里读取,使用 `CONSUL_TOKEN` 和 `VAULT_TOKEN`.强烈建议你不要把token放到未加密的文本配置文件中.

查询 nyc3 demo 的Consul示例, 渲染模板 `/tmp/template.ctmpl` 到`/tmp/result`.运行Consul Template直到服务停止:

```json
consul = "nyc3.demo.consul.io"

template {
  source      = "/tmp/template.ctmpl"
  destination = "/tmp/result"
}
```

如果一个用一个目录替换文件,所以这个目录中的文件会递归的安装Go walk函数的顺序进行合并.所以如果多个文件定义了`consul` key 则最后一个将会被使用,注意,符号链接不会被加入.

**在命令行指定的选项,优先于配置文件**

## 模板语法

Consul Template 使用了Go的模板语法.如果你对他的语法不熟悉建议你读下文档.他的语法看起来与 Mustache, Handlebars, 或者 Liquid 类似.

在Go 提供的模板函数之外,Consul Template暴露了以下的函数:

### API 函数

##### datacenters

查询目录中的所有数据中心.使用以下语法:

```
{{datacenters}}
```

##### file

读取并输出磁盘上的本地文件,如果无法读取产生一个错误.使用如下语法

```
{{file "/path/to/local/file"}}
```

这个例子将输出 `/path/to/local/file` 文件内容到模板. **注意:这不会在嵌套模板中被处理**

##### key

查询Consul指定key的值,如果key的值不能转换为字符串,将产生错误.使用如下语法:

```
{{key "service/redis/maxconns@east-aws"}}
```

上面的例子查询了在`east-aws`数据中心的 `service/redis/maxconns`的值.如果忽略数据中心参数,将会查询本地数据中心的值:

```
{{key "service/redis/maxconns"}}
```

Consul键值结构的美妙在于,这完全取决于你!

##### key_or_default

查询Consul中指定的key的值,如果key不存在,则返回默认值.使用方式如下

```
{{key_or_default "service/redis/maxconns@east-aws" "5"}}
```

注意Consul Template使用了多个阶段的运算.在第一阶段的运算如果Consul没有返回值,则会一直使用默认值.后续模板解析中如果值存在了则会读取真实的值.这很重要,运维Consul Templae不会因为`key_or_default`没找到key而阻塞模板的的渲染.即使key存在如果Consul没有按时返回这个数据,也会使用默认值来进行替代.

##### ls

查看Consul的所有以指定前缀开头的key-value对.如果有值无法转换成字符串则会产生一个错误:

```
{{range ls "service/redis@east-aws"}}
{{.Key}} {{.Value}}{{end}}
```

如果Consul实例在`east-aws`数据中心存在这个结构`service/redis`,渲染后的模板应该类似这样:

```
minconns 2
maxconns 12
```

如果你忽略数据中心属性,则会返回本地数据中心的查询结果.

##### node

查询目录中的一个节点信息

```
{{node "node1"}}
```

如果未指定任何参数,则当前agent所在节点将会被返回:

```
{{node}}
```

你可以指定一个可选的参数来指定数据中心:

```
{{node "node1" "@east-aws"}}
```

如果指定的节点没有找到则会返回`nil`.如果节点存在就会列出节点的信息和节点提供的服务.

```
{{with node}}{{.Node.Node}} ({{.Node.Address}}){{range .Services}}
  {{.Service}} {{.Port}} ({{.Tags | join ","}}){{end}}
{{end}}
```

##### nodes

查询目录中的全部节点,使用如下语法

```
{{nodes}}
```

这个例子会查询Consul的默认数据中心.你可以使用可选参数指定一个可选参数来指定数据中心:

```
{{nodes "@east-aws"}}
```

这个例子会查询`east-aws`数据中心的所有几点.

##### secret

查询`Vault`中指定路径的密匙.如果指定的路径不存在或者`Vault`的Token没有足够权限去读取指定的路径,将会产生一个错误.如果路径存在但是key不存在则返回``.

```
{{with secret "secret/passwords"}}{{.Data.password}}{{end}}
```

可以使用如下字段:

```
LeaseID - the unique lease identifier
LeaseDuration - the number of seconds the lease is valid
Renewable - if the secret is renewable
Data - the raw data - this is a map[string]interface{}, so it can be queried using Go's templating "dot notation"
If the map key has dots "." in it, you need to access the value using the index function:

{{index .Data "my.key.with.dots"}}
If additional arguments are passed to the function, then the operation is assumed to be a write operation instead of a read operation. The write operation must return data in order to be valid. This is especially useful for the PKI secret backend, for example.

{{ with secret "pki/issue/my-domain-dot-com" "common_name=foo.example.com" }}
{{ .Data.certificate }}
{{ end }}
The parameters must be key=value pairs, and each pair must be its own argument to the function:

{{ secret "path/" "a=b" "c=d" "e=f" }}
Please always consider the security implications of having the contents of a secret in plain-text on disk. If an attacker is able to get access to the file, they will have access to plain-text secrets.
```

Please note that Vault does not support blocking queries. As a result, Consul Template will not immediately reload in the event a secret is changed as it does with Consul's key-value store. Consul Template will fetch a new secret at half the lease duration of the original secret. For example, most items in Vault's generic secret backend have a default 30 day lease. This means Consul Template will renew the secret every 15 days. As such, it is recommended that a smaller lease duration be used when generating the initial secret to force Consul Template to renew more often.

##### secrets

Query Vault to list the secrets at the given path. Please note this requires Vault 0.5+ and the endpoint you want to list secrets must support listing. Not all endpoints support listing. The result is the list of secret names as strings.

```
{{range secrets "secret/"}}{{.}}{{end}}
```

The trailing slash is optional in the template, but the generated secret dependency will always have a trailing slash in log output.

To iterate and list over every secret in the generic secret backend in Vault, for example, you would need to do something like this:

```
{{range secrets "secret/"}}
{{with secret (printf "secret/%s" .)}}
{{range $k, $v := .Data}}
{{$k}}: {{$v}}
{{end}}
{{end}}
{{end}}
```

You should probably never do this. Please also note that Vault does not support blocking queries. To understand the implications, please read the note at the end of the secret function.

##### service

查询Consul中匹配表达式的服务.语法如下:

```
{{service "release.web@east-aws"}}
```

上面的例子查询Consul中,在`east-aws`数据中心存在的健康的 `web`服务.tag和数据中心参数是可选的.从当前数据中心查询所有节点的`web`服务而不管tag,查询语法如下:

```
{{service "web"}}
```

这个函数返回`[]*HealthService`结构.可按照如下方式应用到模板:

```
{{range service "web@data center"}}
server {{.Name}} {{.Address}}:{{.Port}}{{end}}
```

产生如下输出:

```
server nyc_web_01 123.456.789.10:8080
server nyc_web_02 456.789.101.213:8080
```

默认值会返回健康的服务,如果你想获取所有服务,可以增加`any`选项,如下:

```
{{service "web" "any"}}
```

这样就会返回注册过的所有服务,而不论他的状态如何.

如果你想过滤指定的一个或者多个健康状态,你可以通过逗号隔开多个健康状态:

```
{{service "web" "passing, warning"}}
```

这样将会返回被他们的节点和服务级别的检查定义标记为 "passing" 或者 "warning"的服务. 请注意逗号是 `OR`而不是`AND`的意思.

指定了超过一个状态过滤,并包含`any`将会返回一个错误.因为`any`是比所有状态更高级的过滤.

后面这2种方式有些架构上的不同:

```
{{service "web"}}
{{service "web" "passing"}}
```

前者会返回Consul认为`healthy`和`passing`的所有服务.后者将返回所有已经在Consul注册的服务.然后会执行一个客户端的过滤.通常如果你想获取健康的服务,你应该不要使用`passing`参数,直接忽略第三个参数即可.然而第三个参数在你想查询 `passing`或者`warning`的服务会比较有用,如下:

```
{{service "web" "passing, warning"}}
```

服务的状态也是可见的,如果你想自己做一些额外的过滤,语法如下:

```
{{range service "web" "any"}}
{{if eq .Status "critical"}}
// Critical state!{{end}}
{{if eq .Status "passing"}}
// Ok{{end}}
```

执行命令时,在Consul将服务设置为维护模式,只需要在你的命令上包上Consul的 `maint` 调用:

```
#!/bin/sh
set -e
consul maint -enable -service web -reason "Consul Template updated"
service nginx reload
consul maint -disable -service web
```

另外如果你没有安装Consul agent,你可以直接调用API请求:

```
#!/bin/sh
set -e
curl -X PUT "http://$CONSUL_HTTP_ADDR/v1/agent/service/maintenance/web?enable=true&reason=Consul+Template+Updated"
service nginx reload
curl -X PUT "http://$CONSUL_HTTP_ADDR/v1/agent/service/maintenance/web?enable=false"
```

##### services

查询Consul目录中的所有服务,使用如下语法:

```
{{services}}
```

这个例子将查询Consul的默认数据中心,你可以指定一个可选参数来指定数据中心:

```
{{services "@east-aws"}}
```

请注意: `services`函数与`service`是不同的,`service`接受更多参数并且查询监控的服务列表.这个查询Consul目录并返回一个服务的tag的Map,如下:

```
{{range services}}
{{.Name}}
{{range .Tags}}
  {{.}}{{end}}
{{end}}
```

##### tree

查询所有指定前缀的key-value值对,如果其中的值有无法转换为字符串的则引发错误:

```
{{range tree "service/redis@east-aws"}}
{{.Key}} {{.Value}}{{end}}
```

如果Consul实例在`east-aws`数据中心有一个`service/redis`结构,模板的渲染结果类似下面:

```
minconns 2
maxconns 12
nested/config/value "value"
```

和`ls`不同,`tree`返回前缀下的所有key.和Unix的tree命令比较像.如果忽略数据中心参数,则会使用本地数据中心

### 帮助函数

##### byKey

将`tree`返回的key-value值对结果创建一个map,这个map根据他们的顶级目录进行组合.例如如果Consul的kv存储如下结构:

```
groups/elasticsearch/es1
groups/elasticsearch/es2
groups/elasticsearch/es3
services/elasticsearch/check_elasticsearch
services/elasticsearch/check_indexes
```

使用下面的模板:

```
{{range $key, $pairs := tree "groups" | byKey}}{{$key}}:
{{range $pair := $pairs}}  {{.Key}}={{.Value}}
{{end}}{{end}}
```

结果如下:

```
elasticsearch:
  es1=1
  es2=1
  es3=1
```

注意顶部的key会被从key的值中剥离出来.如果在剥离前缀后没有前缀,值会被从列表移除.

结果的对会被映射为map,使用可以使用key来访问一个单独的值:

```
{{$weights := tree "weights"}}
{{range service "release.web"}}
  {{$weight := or (index $weights .Node) 100}}
  server {{.Node}} {{.Address}}:{{.Port}} weight {{$weight}}{{end}}
```

##### byTag

将被`service`或者`services`函数返回的列表,按照tag对服务创建Map.

```
{{range $tag, $services := service "web" | byTag}}{{$tag}}
{{range $services}} server {{.Name}} {{.Address}}:{{.Port}}
{{end}}{{end}}
```

##### contains

检查目标是否包含在枚举的元素中

```
{{ if .Tags | contains "production" }}
# ...
{{ end }}
env
```

读取当前进程可以访问的环境变量.

```
{{env "CLUSTER_ID"}}
```

这个函数可以加入管道:

```
{{env "CLUSTER_ID" | toLower}}
```

##### explode

将`tree`或者`ls`的结果转化为深度嵌套的map,用来进行解析和递归.

```
{{ tree "config" | explode }}
```

注意: 解开后,你将丢失所有的关于键值对的元数据.

你可以访问深度嵌套的值:

```
{{ with tree "config" | explode }}
{{.a.b.c}}{{ end }}
```

注意: 你需要在Consul中保存有一个合理的格式的数据.可以查看Go的 text/template包获取更多信息.

##### in

检查目标十分在一个可枚举的元素中.

```
{ if in .Tags "production" }}
# ...
{{ end }}
```

##### loop

接受多个参数,行为受这些参数的影响.

如果给`loop`一个数字,他讲返回一个`goroutine`,开始于0循环直到等于参数的值:

```
{{range loop 5}}
# Comment{{end}}
```

如果给2个数字,则这个函数返回一个 `goroutine` 从第一个数字开始循环直到等于第二个参数的值.

```
{{range $i := loop 5 8}}
stanza-{{$i}}{{end}}
```

渲染结果为:

```
stanza-5
stanza-6
stanza-7
```

Note: It is not possible to get the index and the element since the function returns a goroutine, not a slice. In other words, the following is not valid:

```
# Will NOT work!
{{range $i, $e := loop 5 8}}
# ...{{end}}
```

##### join

将提供的列表作为管道与提供的字符串连接:

```
{{$items | join ","}}
```

##### trimSpace

对输入的内容移除掉空白,tab和换行符

```
{ file "/etc/ec2_version"| trimSpace }}
```

##### parseBool

将给定的字符串解析为布尔值:

```
{{"true" | parseBool}}
```

这个可以与一个key检查和条件检查相结合.如下:

```
{{if key "feature/enabled" | parseBool}}{{end}}
```

##### parseFloat

将给定的字符串解析为 10进制 float64类型数字:

```
{{"1.2" | parseFloat}}
```

##### parseInt

将给定字符串解析为10禁止 int64类型数字:

```
{{"1" | parseInt}}
```

这个可以与其他的帮助函数结合使用,例如:

```
{{range $i := loop key "config/pool_size" | parseInt}}
# ...{{end}}
```

##### parseJSON

将输入,通常是通过key获取的值,解析成JSON

Takes the given input (usually the value from a key) and parses the result as JSON:

```
{{with $d := key "user/info" | parseJSON}}{{$d.name}}{{end}}
```

注意 : Consul Template计算模板很多次.第一次计算时会是空,因为数据还未载入,这意味着我们需要检查空的响应.例如:

```
{{with $d := key "user/info" | parseJSON}}
{{if $d}}
...
{{end}}
{{end}}
```

它只适用简单的key,但是如果你想遍历key或者使用index函数会失败.将要访问的代码包含在 `{{ if $d }}...{{end}}` 之中就够了.

Alternatively you can read data from a local JSON file:

```
{{with $d := file "/path/to/local/data.json" | parseJSON}}{{$d.some_key}}{{end}}
```