docker容器在运行一定时间后会产生大量的日志，导致磁盘空间问题出现
现在有2个方案可以限制docker容器日志文件大小及个数
## 容器范围内
docker run或dokcer create时添加参数
如创建并运行
```bash
docker run --log-opt max-size=10m --log-opt max-file=3
```
## 全局配置
修改docker daemon.json文件，配置日志文件参数
增加对日志文件的设置 /etc/docker/daemon.json
```json
{
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "50m",
		"max-file": "1"
	}
}
```
重启docker
```bash
systemctl daemon-reload
systemctl restart docker
```
