#!/bin/bash
function wget_tar()
			{
				for i in `rpm -qa | grep redis`;do yum -y remove $i;done
				mv -f  redis-5.0.5.tar.gz /usr/local/src/
				cd /usr/local/src
				if [ -f redis-5.0.5.tar.gz ];then
					echo "redis-5.0.5.tar.gz ok"
				else
					wget http://download.redis.io/releases/redis-5.0.5.tar.gz
				fi
			}	
function install_redis()
			{
				set +e
				rm -rf redis-5.0.5
				tar xzvf redis-5.0.5.tar.gz
				which gcc && which c++
				if [ $? -eq 0 ];then
					echo "gcc-c++ is ok"
				else
					yum -y install gcc-c++
				fi
				cd redis-5.0.5;make
				cd src/;make install PREFIX=/usr/local/redis
			}
function create_dir()
			{
				mkdir -p /root/redis/redis-5.0.5/{etc,bin}
				mkdir -p /root/redis/redis-5.0.5/etc/{redis_master,redis_slave1,redis_slave2}
				rm -rf  /root/redis/redis-5.0.5/etc/{redis_master,redis_slave1,redis_slave2}/*
				rm -rf /root/redis/redis-5.0.5/bin/*
				cd /usr/local/src/redis-5.0.5
				cp redis.conf /root/redis/redis-5.0.5/etc/redis_master/
				cp redis.conf /root/redis/redis-5.0.5/etc/redis_slave1/
				cp redis.conf /root/redis/redis-5.0.5/etc/redis_slave2/
				cd /usr/local/src/redis-5.0.5/src
				cp mkreleasehdr.sh redis-benchmark redis-check-aof redis-check-rdb redis-cli redis-server redis-sentinel /root/redis/redis-5.0.5/bin/
			}

function config_master()
			{
				sed -i "s/^bind.*/bind 0.0.0.0/g" /root/redis/redis-5.0.5/etc/redis_master/redis.conf
				master_ip=`cat /tmp/port.list  | grep vm_IP | awk '{print $2}'`
				master_port=`cat /tmp/port.list| grep master| awk '{print $2}'`
				sed -i 's/^port.*/port '${master_port}'/g' /root/redis/redis-5.0.5/etc/redis_master/redis.conf
				sed -i "s/protected-mode.*/protected-mode no/g" /root/redis/redis-5.0.5/etc/redis_master/redis.conf
				sed -i "s/^daemonize.*/daemonize yes/g" /root/redis/redis-5.0.5/etc/redis_master/redis.conf 
				sed -i 's/^pidfile.*/pidfile "\/var\/run\/redis_'${master_port}'.pid"/g' /root/redis/redis-5.0.5/etc/redis_master/redis.conf
				sed -i 's/^logfile.*/logfile "\/root\/redis\/redis-5.0.5\/bin\/redis_'${master_port}'.log"/g' /root/redis/redis-5.0.5/etc/redis_master/redis.conf
				touch  /root/redis/redis-5.0.5/bin/redis_'${master_port}'.log
			}
function config_slave01()
			{
				sed -i "s/^bind.*/bind 0.0.0.0/g" /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf
				slave01_port=`cat /tmp/port.list| grep slave01| awk '{print $2}'`
				master_ip=`cat /tmp/port.list  | grep vm_IP | awk '{print $2}'`
				sed -i 's/^port.*/port '${slave01_port}'/g' /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf
				sed -i "s/protected-mode.*/protected-mode no/g" /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf
				sed -i "s/^daemonize.*/daemonize yes/g" /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf 
				sed -i 's/^pidfile.*/pidfile "\/var\/run\/redis_'${slave01_port}'.pid"/g' /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf
				sed -i 's/^logfile.*/logfile "\/root\/redis\/redis-5.0.5\/bin\/redis_'${slave01_port}'.log"/g' /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf
				touch  /root/redis/redis-5.0.5/bin/redis_'${slave01_port}'.log
				echo "replicaof master_IP master_PORT" >> /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf
				sed -i 's/master_PORT/'${master_port}'/g' /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf 
				sed -i 's/master_IP/'${master_ip}'/g' /root/redis/redis-5.0.5/etc/redis_slave1/redis.conf
			}
function config_slave02()
			{
				sed -i "s/^bind.*/bind 0.0.0.0/g" /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf
				slave02_port=`cat /tmp/port.list| grep slave02| awk '{print $2}'`
				master_ip=`cat /tmp/port.list  | grep vm_IP | awk '{print $2}'`
				sed -i 's/^port.*/port '${slave02_port}'/g' /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf
				sed -i "s/protected-mode.*/protected-mode no/g" /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf
				sed -i "s/^daemonize.*/daemonize yes/g" /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf 
				sed -i 's/^pidfile.*/pidfile "\/var\/run\/redis_'${slave02_port}'.pid"/g' /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf
				sed -i 's/^logfile.*/logfile "\/root\/redis\/redis-5.0.5\/bin\/redis_'${slave02_port}'.log"/g' /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf
				touch  /root/redis/redis-5.0.5/bin/redis_'${slave02_port}'.log
				echo "replicaof master_IP master_PORT" >> /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf
				sed -i 's/master_PORT/'${master_port}'/g' /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf 
				sed -i 's/master_IP/'${master_ip}'/g' /root/redis/redis-5.0.5/etc/redis_slave2/redis.conf
				for i in `netstat -nlpt | grep redis-serve | awk '{print $7}' | awk -F/ '{print $1}'|sort -rn|uniq -c | awk '{print $2}'`;do kill -9 $i;done
				sh /tmp/start_redis.sh 
			}

function config_soldier()
			{
				cd /usr/local/src/redis-5.0.5/
				master_ip=`cat /tmp/port.list  | grep vm_IP | awk '{print $2}'`
				master_port=`cat /tmp/port.list| grep master| awk '{print $2}'`
				slave01_port=`cat /tmp/port.list| grep slave01| awk '{print $2}'`
				slave02_port=`cat /tmp/port.list| grep slave02| awk '{print $2}'`
				cp sentinel.conf /root/redis/redis-5.0.5/etc/redis_master/
				cp sentinel.conf /root/redis/redis-5.0.5/etc/redis_slave1/
				cp sentinel.conf /root/redis/redis-5.0.5/etc/redis_slave2/
				soldier01=`cat /tmp/port.list  | grep soldier01 | awk '{print $2}'`
				soldier02=`cat /tmp/port.list  | grep soldier02 | awk '{print $2}'`
				soldier03=`cat /tmp/port.list  | grep soldier03 | awk '{print $2}'`
				sed -i 's/# bind.*/bind '${master_ip}'/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf
				sed -i 's/# bind.*/bind '${master_ip}'/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf
				sed -i 's/# bind.*/bind '${master_ip}'/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf
				sed -i 's/^port.*/port '${soldier01}'/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf
				sed -i 's/^port.*/port '${soldier02}'/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf
				sed -i 's/^port.*/port '${soldier03}'/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf
				sed -i 's/# protected-mode no/protected-mode yes/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf
				sed -i 's/# protected-mode no/protected-mode yes/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf
				sed -i 's/# protected-mode no/protected-mode yes/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf
				sed -i 's/^daemonize.*/daemonize yes/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf
				sed -i 's/^daemonize.*/daemonize yes/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf
				sed -i 's/^daemonize.*/daemonize yes/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf
				sed -i 's/^pidfile.*/pidfile "\/var\/run\/redis-sentinel_'${slave01_port}'.pid"/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf 
				sed -i 's/^pidfile.*/pidfile "\/var\/run\/redis-sentinel_'${slave02_port}'.pid"/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf 
				sed -i 's/^pidfile.*/pidfile "\/var\/run\/redis-sentinel_'${slave03_port}'.pid"/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf 
				sed -i 's/^logfile.*/logfile "\/root\/redis\/redis-5.0.5\/bin\/sentinel_'${slave01_port}'.log"/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf	
				sed -i 's/^logfile.*/logfile "\/root\/redis\/redis-5.0.5\/bin\/sentinel_'${slave02_port}'.log"/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf	
				sed -i 's/^logfile.*/logfile "\/root\/redis\/redis-5.0.5\/bin\/sentinel_'${slave03_port}'.log"/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf	
				sed -i 's/sentinel monitor.*/sentinel monitor mymaster '${master_ip}' '${master_port}' 2/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf
				sed -i 's/sentinel monitor.*/sentinel monitor mymaster '${master_ip}' '${master_port}' 2/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf
				sed -i 's/sentinel monitor.*/sentinel monitor mymaster '${master_ip}' '${master_port}' 2/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf	
				sed -i 's/sentinel down-after-milliseconds.*/sentinel down-after-milliseconds mymaster 3000/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf
				sed -i 's/sentinel down-after-milliseconds.*/sentinel down-after-milliseconds mymaster 3000/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf
				sed -i 's/sentinel down-after-milliseconds.*/sentinel down-after-milliseconds mymaster 3000/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf
				sed -i 's/^sentinel parallel-syncs.*/sentinel parallel-syncs mymaster 1/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf
				sed -i 's/^sentinel parallel-syncs.*/sentinel parallel-syncs mymaster 1/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf
				sed -i 's/^sentinel parallel-syncs.*/sentinel parallel-syncs mymaster 1/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf
				sed -i 's/^sentinel failover-timeout.*/sentinel failover-timeout mymaster 180000/g' /root/redis/redis-5.0.5/etc/redis_master/sentinel.conf
				sed -i 's/^sentinel failover-timeout.*/sentinel failover-timeout mymaster 180000/g' /root/redis/redis-5.0.5/etc/redis_slave1/sentinel.conf
				sed -i 's/^sentinel failover-timeout.*/sentinel failover-timeout mymaster 180000/g' /root/redis/redis-5.0.5/etc/redis_slave2/sentinel.conf
				for i in `netstat -nlpt | grep redis-senti | awk '{print $7}' | awk -F/ '{print $1}'|sort -rn|uniq -c | awk '{print $2}'`;do kill -9 $i;done
				sh /tmp/start_soldier.sh
			}

wget_tar
install_redis
create_dir
config_master
config_slave01
config_slave02
config_soldier
