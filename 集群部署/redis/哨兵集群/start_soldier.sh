#!/bin/bash
#start)
	cd /root/redis/redis-5.0.5/bin/
		./redis-sentinel ../etc/redis_master/sentinel.conf
		./redis-sentinel ../etc/redis_slave1/sentinel.conf
		./redis-sentinel ../etc/redis_slave2/sentinel.conf
