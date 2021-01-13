### 操作步骤
将想要上传到nexus的文件上传到服务器中，然后在这个目录下执行下面这个脚本（必须是根目录）
### 脚本说明
执行脚本testnexus.sh内容
```bash
while getopts ":r:u:p:" opt; do
	case $opt in
		r) REPO_URL="$OPTARG"
		;;
		u) USERNAME="$OPTARG"
		;;
		p) PASSWORD="$OPTARG"
		;;
	esac
done
 
find . -type f -not -path './bacthimports\.sh*' -not -path '*/\.*' -not -path '*/\^archetype\-catalog\.xml*' -not -path '*/\^maven\-metadata\-local*\.xml' -not -path '*/\^maven\-metadata\-deployment*\.xml' | sed "s|^\./||" | xargs -I '{}' curl -u "$USERNAME:$PASSWORD" -X PUT -v -T {} ${REPO_URL}/{} ;
```
执行脚本 testnexus.sh 命令
```bash
sh testnexus.sh -u admin -p admin -r http://192.168.2.184:8081/repository/maven-releases/
```
### 备注
- 推送jar包要到对应的仓库，比如release版本就推送到release的仓库，快照就推送到快照的仓库
