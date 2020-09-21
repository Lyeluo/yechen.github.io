### kubernetes拉取私有镜像仓库时需要使用镜像仓库的账号密码
方式：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: quay.io/<Quay profile name>/<image name>
  imagePullSecrets:
  - name: harborSecret
```
### 上面指定了私有镜像仓库的秘钥存在`harborSecret`中。  
创建secret
```bash
kubectl create secret docker-registry harborSecret \
    --docker-server=quay.io \
    --docker-username=<Profile name> \
    --docker-password=<password>
```
查看secret
```bash
kubectl get secret harborSecret --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode
```
