## 安装rancher-cli
参考地址 http://www.eryajf.net/2734.html

## 安装kubectl

#### jenkins报错：command not found
- 方案一：如果你使用service jenkins start启动了jenkins进程，那么久有可能出现Jenkins运行环境跟用户不同。最简单粗暴的方法是使用 java -jar /usr/lib/jenkins/kenkins.war
- 方案二：把要用的命令创建一个快捷方式到/usr/bin，如 ln -s /usr/local/bin/node /usr/bin/，这样在Jenkins shell中就能用到node命令了。当然如果是node命令找不到的话可以直接使用Nodejs Plugin解决


## 配置token
