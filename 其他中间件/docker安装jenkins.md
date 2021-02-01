
```bash
docker run \
  -u root \
  --restart=always \
  --name=ecs-jenkins \
  -d \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /opt/jenkins/jenkins_home:/var/jenkins_home \
  -v /usr/bin/rancher:/usr/bin/rancher \
  -v /usr/bin/kubectl:/usr/bin/kubectl \
  -v /root/.rancher/cli2.json:/root/.rancher/cli2.json \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkinsci/blueocean
```
首次部署，查看管理员密码
```bash
docker exec ecs-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
