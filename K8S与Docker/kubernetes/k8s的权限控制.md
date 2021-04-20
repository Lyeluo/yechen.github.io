## role和roleBinding
Role资源定义了哪些操作可以在哪些资源上执行。也可以直接控制访问的url的权限，下面的cluster也是这样。
查询所有service的demo：
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  # role的命名空间，如果没有则默认为当前命名空间
  namespace: foo
  name: service-reader
rules:
  # service是核心apiGroup的资源，所以没有apiGroup的名，就是“”
  - apiGroups: [""]
    # 允许查询和返回所有允许的服务
    verbs:
      - "get"
      - "list"
    # 说明这条规则和服务有关
    resources:
      - "services"
```
**注意：** 在指定资源时，必须采用复数形式！如：services

角色定义了哪些操作可以执行，但没有指定谁可以执行这些操作。要做到这一
点，必须将角色绑定到一个主体，它可以是一个user (用户）、 一个ServiceAccount或一个组（用户或 ServiceAccount 组）。  
也就是说`RoleBinding`就是一个中间表，主要负责维护"角色"和用户的关系。而这里的用户可以使user、serviceAccount或者serviceAccount group
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: foo
  name: test
# 绑定的role  
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: service-reader
# 绑定的用户 
subjects:
  - kind: ServiceAccount
    name: foo
    namespace: default
```
上面的配置中给service-reader的角色绑定了default命名空间中名称为foo的ServiceAccount，也就是说在foo命名空间中的pod，只要
引用了foo的ServiceAccount，就拥有了service-reader的角色权限。  
同样的，如果将service-reader的角色绑定到其他的命名空间的ServiceAccount，那么其他命名空间的pod，也可以拥有service-reader的
角色权限，也就是访问foo中的service资源。  
## ClusterRole和ClusterRoleBinding
上面通过Role我们可以获得了部分操作命名空间的权限。但是有些资源不属于命名空间自身，如：pv、role、或者namespace自身。
这个时候就需要用到了ClusterRole和ClusterRoleBinding。  
集群级别的资源访问ClusterRole必须和ClusterRoleBinding绑定才会生效。因为这些资源本身就不属于命名空间之内的，而roleBinding
都是针对命名空间内的资源生效的。  
可以查看k8s内置的一个clusterRole
```bash
kubectl get clusterrole system:discovery -o yaml
```
这个cluterRole提供了对一些公共的url访问的权限，如：healthz、version等
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2020-04-29T06:32:17Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:discovery
  resourceVersion: "42"
  selfLink: /apis/rbac.authorization.k8s.io/v1/clusterroles/system%3Adiscovery
  uid: 406bba95-3344-4650-8b00-1afb55d7321f
rules:
- nonResourceURLs:
  - /api
  - /api/*
  - /apis
  - /apis/*
  - /healthz
  - /livez
  - /openapi
  - /openapi/*
  - /readyz
  - /version
  - /version/
  verbs:
  - get
```
注意：对于URL权限的控制，要使用普通的HTTP动词，如：post、get、patch等，必须使用小写。而不是create或者update  
非资源型URL clusterRole和集群级别的资源一样，只能与clusterRoleBinding结合使用。  
查看官方中此clusterRole对应的clusterRoleBinding
```bash
kubectl get clusterrolebinding system:discovery -o yaml
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2020-04-29T06:32:17Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:discovery
  resourceVersion: "93"
  selfLink: /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/system%3Adiscovery
  uid: cc81c481-e70b-406b-bde8-c25c811102cd
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:discovery
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:authenticated
```
可以看到上面的ClusterRoleBinding，赋予了所有已登录的用户system:discovery的ClusterRole的权限。
## ClusterRole与RoleBinding
ClusterRole不是必须与ClusterRoleBinding结合使用。当需要访问命名空间级别的资源时，可以使用ClusterRole定义这些权限，
然后使用RoleBinding与具体的命名空间中的serviceAccount绑定。然后这个命名空间下的pod，应用了这个serviceAccount后，就
获得了访问所有命名空间中的资源的权限。如：
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: view
rules:
    apiGroups:
      - ""
    # 指定可以访问的资源的权限，注意：这里全部都是命名空间中的资源
    resources:
      - configmaps
      - endpoints
      - persistenvolumeclaims
      - pods
      - replicationcontrollers
      - replicationcontrollers/scale
      - serviceaccounts
      - services
    # 指定权限为查看
    verbs:
      - get
      - list
      - watch
```
---
为了防止权限扩散，建议为每个pod或一组pod，创建一个特定的serviceAccount，并且把它和一个定制的role或者clusterRole通过roleBinding
联系起来（不使用clusterRoleBinding是因为这样做会给其他命名空间的pod对资源的访问权限，只要他们指定这个命名，这样做是很危险的）
