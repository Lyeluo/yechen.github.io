ab -n 100 -c 10  -p "post.txt" -T "application/x-www-form-urlencoded" -H "LoginToken: 9ce8750e60d211ea81fa139a15bbf1d5" -H "Content-Type: application/json" -k -s 50 "http://192.168.12.182:9098/fssc/bo/boQuery/getBOQueryDataList"
{"boDefineId":"5f0971df7a4411e9b0edd9fcadd69462","appId":"e3d5e4787ff911e88b1997bee3518b4d","order":"NONE","relationBO":{"boType":"OBJECT_TYPE","boDefineId":"5f0971df7a4411e9b0edd9fcadd69462"},"conditions":"","conditionMap":{"5f61a40b7a4411e9b0ed8f1fef5be668":"","ba31ef167a4411e9b0ed9162dd502459":"","d3f7fcbc7a4411e9b0ed576d29ce88e9":"","9ac561067ad511e9a370c99a7e4e7796":"","d57ecfff8cf311e98f5a61c1477748e5":""},"pageOrderParam":{"pageNum":1,"pageSize":20},"boQuerySheetId":"5aed7c3c7dfa11e9b2ac5f147cbcad31","authority":0}

````java

````
