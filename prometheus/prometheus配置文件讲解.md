## relabel_configs 
___action：重新标签动作___
- replace：默认，通过regex匹配source_label的值，使用replacement来引用表达式匹配的分组
- keep：删除regex与连接不匹配的目标 source_labels
- drop：删除regex与连接匹配的目标 source_labels
- labeldrop：删除regex匹配的标签
- labelkeep：删除regex不匹配的标签
- hashmod：设置target_label为modulus连接的哈希值source_labels
- labelmap：匹配regex所有标签名称。然后复制匹配标签的值进行分组，replacement分组引用（${1},${2},…）替代
```conf
relable_configs:
  # 源标签
  [ source_labels: '[' <labelname> [, ...] ']' ]
  
  # 多个源标签时连接的分隔符
  [ separator: <string> | default = ; ]
  
  # 将原标签替换为
  [ target_label: <labelname> ]
  
  # 正则表达式匹配源标签的值
  [ regex: <regex> | default = (.*) ]
  
  # 源标签值的散列取的模数
  [ modulus: <uint64> ]
  
  # 替换正则表达式匹配的分组，分组引用 $1,$2,$3,....
  [ replacement: <string> | default = $1 ]
  
  # 基于正则表达式匹配执行的操作
  [ action: <relabel_action> | default = replace ]
```
