## 使用kibana创建索引报错
```
blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];: [cluster_block_exception] blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];
```
+ 在kibana的开发工具中调用如下请求
```
PUT _settings
    {
    "index": {
    "blocks": {
    "read_only_allow_delete": "false"
    }
    }
    }
```
## 传输数据到ES时报错
```
[CjcbNTZ] flood stage disk watermark [95%] exceeded on [CjcbNTZyTs22BbwE7GXHbw][CjcbNTZ][/opt/servers/work/elasticsearch-6.2.3/data/nodes/0] free: 430.7mb[0.8%], all indices on this node will marked read-only
```
+ 报错原因：磁盘空间不足  
+ 处理方法：定时清理es的磁盘空间
+ 清理elasticsearch的脚本如下  
```bash
#只保留15天内的日志索引
LAST_DATA=`date -d "-15 days" "+%Y.%m.%d"`
#删除上个月份所有的索引
curl -XDELETE 'http://192.168.2.186:9200/*-'${LAST_DATA}'*'
```
