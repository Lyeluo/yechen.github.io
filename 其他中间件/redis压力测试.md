## Redis压力测试
+ 版本：redis-5.0.7
+ 工具：redis-benchmark
+ 服务器版本：CentOS Linux release 7.7.1908 (Core)
+ 服务器CPU：4核16G  
结果如下：
```
====== PING_INLINE ======
  100000 requests completed in 1.70 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.41% <= 1 milliseconds
100.00% <= 1 milliseconds
58962.27 requests per second

====== PING_BULK ======
  100000 requests completed in 1.76 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.31% <= 1 milliseconds
100.00% <= 2 milliseconds
100.00% <= 2 milliseconds
56785.91 requests per second

====== SET ======
  100000 requests completed in 1.75 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

98.88% <= 1 milliseconds
100.00% <= 2 milliseconds
57045.07 requests per second

====== GET ======
  100000 requests completed in 1.71 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.64% <= 1 milliseconds
100.00% <= 1 milliseconds
58651.02 requests per second

====== INCR ======
  100000 requests completed in 1.70 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.66% <= 1 milliseconds
100.00% <= 2 milliseconds
100.00% <= 2 milliseconds
58927.52 requests per second

====== LPUSH ======
  100000 requests completed in 1.78 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.32% <= 1 milliseconds
100.00% <= 1 milliseconds
56148.23 requests per second

====== RPUSH ======
  100000 requests completed in 1.69 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.62% <= 1 milliseconds
100.00% <= 2 milliseconds
100.00% <= 2 milliseconds
59101.65 requests per second

====== LPOP ======
  100000 requests completed in 1.69 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.57% <= 1 milliseconds
100.00% <= 1 milliseconds
59101.65 requests per second

====== RPOP ======
  100000 requests completed in 1.69 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.46% <= 1 milliseconds
100.00% <= 1 milliseconds
59311.98 requests per second

====== SADD ======
  100000 requests completed in 1.75 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.48% <= 1 milliseconds
100.00% <= 2 milliseconds
57110.22 requests per second

====== HSET ======
  100000 requests completed in 1.67 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.68% <= 1 milliseconds
99.99% <= 2 milliseconds
100.00% <= 2 milliseconds
60024.01 requests per second

====== SPOP ======
  100000 requests completed in 1.70 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.38% <= 1 milliseconds
99.98% <= 2 milliseconds
100.00% <= 2 milliseconds
58892.82 requests per second

====== LPUSH (needed to benchmark LRANGE) ======
  100000 requests completed in 1.79 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

98.92% <= 1 milliseconds
99.96% <= 2 milliseconds
99.99% <= 3 milliseconds
100.00% <= 3 milliseconds
55991.04 requests per second

====== LRANGE_100 (first 100 elements) ======
  100000 requests completed in 2.96 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

85.31% <= 1 milliseconds
99.41% <= 2 milliseconds
99.97% <= 3 milliseconds
100.00% <= 3 milliseconds
33806.62 requests per second

====== LRANGE_300 (first 300 elements) ======
  100000 requests completed in 6.72 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

0.20% <= 1 milliseconds
81.79% <= 2 milliseconds
97.51% <= 3 milliseconds
99.40% <= 4 milliseconds
99.75% <= 5 milliseconds
99.93% <= 6 milliseconds
99.98% <= 7 milliseconds
100.00% <= 8 milliseconds
100.00% <= 8 milliseconds
14869.89 requests per second

====== LRANGE_500 (first 450 elements) ======
  100000 requests completed in 8.68 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

0.05% <= 1 milliseconds
25.94% <= 2 milliseconds
92.68% <= 3 milliseconds
98.14% <= 4 milliseconds
99.36% <= 5 milliseconds
99.73% <= 6 milliseconds
99.90% <= 7 milliseconds
99.98% <= 8 milliseconds
99.99% <= 9 milliseconds
100.00% <= 10 milliseconds
11515.43 requests per second

====== LRANGE_600 (first 600 elements) ======
  100000 requests completed in 11.11 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

0.02% <= 1 milliseconds
0.96% <= 2 milliseconds
75.38% <= 3 milliseconds
95.24% <= 4 milliseconds
98.35% <= 5 milliseconds
99.37% <= 6 milliseconds
99.66% <= 7 milliseconds
99.79% <= 8 milliseconds
99.89% <= 9 milliseconds
99.96% <= 10 milliseconds
99.99% <= 11 milliseconds
100.00% <= 11 milliseconds
8996.85 requests per second

====== MSET (10 keys) ======
  100000 requests completed in 1.71 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

97.04% <= 1 milliseconds
99.98% <= 2 milliseconds
100.00% <= 2 milliseconds
58513.75 requests per second

```

