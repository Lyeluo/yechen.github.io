1 启用 ELRepo 仓库：
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

2 更新仓库
yum -y update

3 查看可用的系统内核包
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available


4 安装最新内核
旧内核:
rpm -qa | grep kernel

kernel-3.10.0-693.el7.x86_64
kernel-3.10.0-1127.18.2.el7.x86_64
kernel-tools-3.10.0-1127.18.2.el7.x86_64
kernel-tools-libs-3.10.0-1127.18.2.el7.x86_64

安装新版本：
查一下所有系统内核信息
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
0 : CentOS Linux (3.10.0-1127.18.2.el7.x86_64) 7 (Core)
1 : CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)
2 : CentOS Linux (0-rescue-ab393fd804fb44a98d15e2427fb373f8) 7 (Core)

安装内核:
##yum --enablerepo=elrepo-kernel install kernel-ml
yum --enablerepo=elrepo-kernel install kernel-lt -y


5.设置 grub2
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
其中 0 是上面查询出来的可用内核
grub2-set-default 0

重新生成grub2 参数
grub2-mkconfig -o $(find /boot -name grub.cfg)
reboot
6 卸载其他内核
rpm -qa | grep kernel
yum remove kernel-3.10.0-693.el7.x86_64 kernel-3.10.0-1127.18.2.el7.x86_64 kernel-tools-3.10.0-1127.18.2.el7.x86_64 kernel-tools-libs-3.10.0-1127.18.2.el7.x86_64
