#!/bin/bash
CURRENT_PATH=$(pwd);echo $CURRENT_PATH
function install_ipvsadm()
		{
			cd ${CURRENT_PATH}
			which gcc && which c++
			if [ $? -eq 0 ];then
				echo "gcc-c++ ok"
			else	
				yum -y install gcc-c++
			fi
			which wget
			if [ $? -eq 0 ];then
				echo "wget ok"
			else	
				yum -y install wget
			fi
			if [ -f ipvsadm-1.26.tar.gz ];then
				echo "ipvsadm-1.26.tar.gz ok"
			else
				wget http://linuxvirtualserver.org/software/kernel-2.6/ipvsadm-1.26.tar.gz
			fi
			modprobe -l |grep ipvs | grep -E "ip_vs_rr.ko|ip_vs_sh.ko"
			if [ $? -eq 0 ];then
				echo "env ok"
			else
				echo "kernel is not match with ipvsadm"
			fi
			cd ipvsadm-1.26;make uninstall
			cd ${CURRENT_PATH}
			rm -rf ipvsadm-1.26;tar zxvf ipvsadm-1.26.tar.gz
			cd ipvsadm-1.26
			yum -y install popt* yum -y install libnl*
			rpm -qa | grep openssl-devel
			if [ $? -eq 0 ];then
				echo "openssl-devel is ok"
			else
				yum -y install openssl-devel
			fi
			make && make install
		}
function install_keepalived()
		{
			cd ${CURRENT_PATH}
			mkdir -p /etc/keepalived/
			if [ -f keepalived-2.0.2.tar.gz ];then
				echo "keepalived-2.0.2.tar.gz ok"
			else
				wget https://www.keepalived.org/software/keepalived-2.0.2.tar.gz
			fi
			rm -rf keepalived-2.0.2;tar zxvf keepalived-2.0.2.tar.gz
			rm -rf /usr/local/keepalived;rm -rf /etc/keepalived/*
			cd keepalived-2.0.2
			./configure --prefix=/usr/local/keepalived --sysconf=/etc
			make && make install
		}
			
function config_keepalived()
		{
			rm -rf /etc/keepalived/keepalived.conf
			cp ${CURRENT_PATH}/keepalived.conf  /etc/keepalived/keepalived.conf
			VIPPORT=`cat ${CURRENT_PATH}/port.list | grep PORT |awk '{print $2}'`
			VIP=`cat ${CURRENT_PATH}/port.list  | grep VIP |awk '{print $2}'`
			BROADCAST=`cat ${CURRENT_PATH}/port.list | grep BROADCAST | awk '{print $2}'`
			REALY01=`cat ${CURRENT_PATH}/port.list | grep REALY01 | awk '{print $2}'`
			REALY02=`cat ${CURRENT_PATH}/port.list | grep REALY02 | awk '{print $2}'`
			sed -i 's/VIPPORT/'${VIPPORT}'/g' /etc/keepalived/keepalived.conf
			sed -i 's/VIP4399/'${VIP}'/g' /etc/keepalived/keepalived.conf	
			sed -i 's/REALY01/'${REALY01}'/g' /etc/keepalived/keepalived.conf
			sed -i 's/REALY02/'${REALY02}'/g' /etc/keepalived/keepalived.conf
			sed -i 's/BROADCAST/'${BROADCAST}'/g' /etc/keepalived/keepalived.conf 
			sed -i "s/priority.*/priority 80/g" /etc/keepalived/keepalived.conf 
			sed -i "s/state.*/state BACKUP/g" /etc/keepalived/keepalived.conf
			cd ${CURRENT_PATH}
                        if [ -f realserver.sh.bak ];then
                                rm -rf realserver.sh;cp realserver.sh.bak realserver.sh
                        else
                                mv -f  realserver.sh realserver.sh.bak
                                cp realserver.sh.bak realserver.sh
                        fi
			sed -i 's/VIP/'${VIP}'/g' ${CURRENT_PATH}/realserver.sh	
			systemctl daemon-reload
			systemctl restart keepalived
		}

install_ipvsadm
install_keepalived
config_keepalived
