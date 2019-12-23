## grok语法错误导致elasticsearch分词缺少字段  
```
logstash的grok语法如下：
 grok {
        match => { "message" => "%{GREEDYDATA:date} %{GREEDYDATA:timer} %{LOGLEVEL:loglevel} %{GREEDYDATA:serviceName} %{GREEDYDATA:hostName}  %{GREEDYDATA:className} \[File = %{GREEDYDATA:classFile}\] \[Line = %{NUMBER:classLine}\] \[Method = %{GREEDYDATA:classMethod}\] \[%{GREEDYDATA:logModule}\] %{GREEDYDATA:log-context}"}
         }

错误一：
    grok语法中服务器IP应该使用的表达式为：%{IP:hostName}
    log4j服务中配置的日志输出格式中ip的输出应该是：%h 而不是 [hostName = %h]，注意 这里的%h是我在代码中自定义的

错误二：
    表达式中%{GREEDYDATA:hostName}  %{GREEDYDATA:className}中间出现了两个空格，grok的格式校验是很严格的，一定要注意空格的问题
    可以在下面网址中校验完毕后再去lostash中配置。https://grokdebug.herokuapp.com/

正确的语法如下：
     grok {
        match => { "message" => "%{GREEDYDATA:date} %{GREEDYDATA:timer} %{LOGLEVEL:loglevel} %{GREEDYDATA:serviceName} %{IP:hostName} %{GREEDYDATA:className} \[File = %{GREEDYDATA:classFile}\] \[Line = %{NUMBER:classLine}\] \[Method = %{GREEDYDATA:classMethod}\] \[%{GREEDYDATA:logModule}\] %{GREEDYDATA:log-context}"}
         }
    
```


