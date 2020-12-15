#!/bin/bash
#start)
	cd /root/redis/redis-5.0.5/bin
	./redis-server ../etc/redis_master/redis.conf
	./redis-server ../etc/redis_slave1/redis.conf
	./redis-server ../etc/redis_slave2/redis.conf
