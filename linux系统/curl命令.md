curl -o /dev/null -s -w ‘%{time_namelookup}-%{time_connect}-%{time_starttransfer}-%{time_total}-%{speed_download}’
 -H 'appId: e3d5e4787ff911e88b1997bee3518b4d' -H 'Authorization: Basic YWRtaW46YWRtaW4='
  -H 'LoginToken: d059397d740811ea8b27674ad70a9572' -H 'MenuId: 56dd24a4a5bf11e8a1a18b0a6e0bad88' 
  -d '{"billMainId":"05e3dc71051611eaa79177292099bd7c","scene":"OPERATOR_VIEW"}'
   http://ms-gateway-hisense-yuanian-test.devapps.hisense.com/fssc/bill/billdata/getBillDataAndTemplateByBillMainId
   
   
   
time_namelookup：DNS 解析域名的时间
time_connect：client和server端建立TCP 连接的时间
time_starttransfer：从client发出请求；到web的server 响应第一个字节的时间
time_total：client发出请求；到web的server发送会所有的相应数据的时间
speed_download：下载速度 单位 byte/s


 
 
 
