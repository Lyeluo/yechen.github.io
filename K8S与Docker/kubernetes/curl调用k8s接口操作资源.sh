#!/bin/bash

#接受参数
#_PROJECT_NAME  项目名称
#_GIT_TAG       项目标签
#_CONTEXT       编译项目环境
#_APP_CONF      程序环境配置
#_API_VERSION   k8s接口版本 apps/v1beta1 apps/v1
#_GIT_USERNAME  git账号
#_GIT_PASSWORD  git密码
#_CPU           处理器资源分配(纯数字)
#_MEMORY        内存资源分配(纯数字)
#_BUILD         构建镜像 yes
#_RELEASE_MODE  发布方式 new/update
#_BUILD_SERVER_USERNAME 镜像编译服务器账号
#_BUILD_SERVER_PASSWORD 镜像编译服务器密码
#_IMAGE_SERVER_USERNAME 镜像库服务器账号
#_IMAGE_SERVER_PASSWORD 镜像库服务器密码
#_K8S_API_TOKEN         容器集群token，即rancher中创建的api token
#_K8S_API_IP  rancher中kubeconfig中的rancherurl 如：https://192.168.12.119/k8s/clusters/c-2tfwz
COMMANDLINE="$*"
for COMMAND in $COMMANDLINE
do
    key=$(echo $COMMAND | awk -F"=" '{print $1}')
    val=$(echo $COMMAND | awk -F"=" '{print $2}')
    case $key in
        --_PROJECT_NAME)
            _PROJECT_NAME=$val
        ;;
        --_GIT_TAG)
            _GIT_TAG=$val
        ;;
        --_CONTEXT)
            _CONTEXT=$val
        ;;
        --_APP_CONF)
            _APP_CONF=$val
        ;;
        --APP_CONF)
            APP_CONF=$val
        ;;
        --_API_VERSION)
            _API_VERSION=$val
        ;;
        --_GIT_USERNAME)
            _GIT_USERNAME=$val
        ;;
        --_GIT_PASSWORD)
            _GIT_PASSWORD=$val
        ;;
        --_AUTH)
            _AUTH=$val
        ;;
        --_CPU)
            _CPU=$val
        ;;
        --_MEMORY)
            _MEMORY=$val
        ;;
        --_BUILD)
            _BUILD=$val
        ;;
        --_RELEASE_MODE)
            _RELEASE_MODE=$val
        ;;
        --_BUILD_SERVER_USERNAME)
            _BUILD_SERVER_USERNAME=$val
        ;;
        --_BUILD_SERVER_PASSWORD)
            _BUILD_SERVER_PASSWORD=$val
        ;;
        --_IMAGE_SERVER_USERNAME)
            _IMAGE_SERVER_USERNAME=$val
        ;;
        --_IMAGE_SERVER_PASSWORD)
            _IMAGE_SERVER_PASSWORD=$val
        ;;
        --_K8S_API_TOKEN)
            _K8S_API_TOKEN=$val
        ;;
    esac
done

#项目目录初始化
APP_ROOT=$(dirname "$0")/..
JDK_ROOT=${APP_ROOT}/plugin/jdk1.8.0_191
ANT_ROOT=${APP_ROOT}/plugin/apache-ant-1.10.10
MVN_ROOT=${APP_ROOT}/plugin/apache-maven-3.6.3
DOTNET_ROOT=${APP_ROOT}/plugin/dotnet-sdk-2.1.816-linux-x64
NODE_ROOT=${APP_ROOT}/plugin/node-v14.17.0-linux-x64

BUILD_ROOT=${APP_ROOT}/build
CONF_ROOT=${APP_ROOT}/conf
PROJECT_ROOT=${APP_ROOT}/project

#服务器参数
source $CONF_ROOT/conf_$_CONTEXT.sh

#目录
echo APP_ROOT:"$APP_ROOT"
echo JDK_ROOT:"$JDK_ROOT"
echo ANT_ROOT:"$ANT_ROOT"
echo MVN_ROOT:"$MVN_ROOT"
echo DOTNET_ROOT:"$DOTNET_ROOT"
echo NODE_ROOT:"$NODE_ROOT"
echo BUILD_ROOT:"$BUILD_ROOT"
echo CONF_ROOT:"$CONF_ROOT"
echo PROJECT_ROOT:"$PROJECT_ROOT"
echo "----------------------------------------------------------------------------------------------------"
echo
echo
echo
echo
echo

#maven环境配
source $APP_ROOT/bin/init_mvn.sh \
--MVN_ROOT=$MVN_ROOT

#JDK环境配
source $APP_ROOT/bin/init_jdk.sh \
--JDK_ROOT=$JDK_ROOT

#DOTNET环境配置
source $APP_ROOT/bin/init_dotnet.sh \
--DOTNET_ROOT=$DOTNET_ROOT

#NODE环境配置
source $APP_ROOT/bin/init_node.sh \
--NODE_ROOT=$NODE_ROOT

##组件检测
#source $APP_ROOT/bin/init_test.sh \
#--ANT_ROOT=$ANT_ROOT \
#--MVN_ROOT=$MVN_ROOT

#获取项目信息
source $BUILD_ROOT/$_PROJECT_NAME.sh

#调用git
#DIR_NAME     项目目录名称
#GIT_USERNAME git账号
#GIT_PASSWORD git密码
#GIT_URL      git源码地址
#GIT_TAG      源码标签
#PROJECT_ROOT 源码根目录
#CONTEXT      环境 dev utest release
#AUTH         是否使用账户密码 yes or other
if [ $_BUILD == "yes" ]; then
    source $APP_ROOT/bin/git.sh \
    --DIR_NAME=$name \
    --GIT_USERNAME=$_GIT_USERNAME \
    --GIT_PASSWORD=$_GIT_PASSWORD \
    --GIT_URL=$url \
    --GIT_TAG=$_GIT_TAG \
    --PROJECT_ROOT=$PROJECT_ROOT \
    --CONTEXT=$_CONTEXT \
    --AUTH=$_AUTH
fi

#编译
#ANT_ROOT              ANT根目录
#TYPE                  项目类型
#DIR_NAME              项目目录名称
#CONTEXT               项目运行的环境
#APP_CONF              项目配置目录
#BUILD_SERVER_IP       编译镜像服务器地址
#BUILD_SERVER_PORT     编译镜像服务器端口
#BUILD_SERVER_USERNAME 编译镜像服务器账户
#BUILD_SERVER_PASSWORD 编译镜像服务器密码
#PROJECTPORT           项目开放的端口
#GIT_TAG               项目标签,用于标记版本
#IMAGE_SERVER_IP       镜像库地址
#IMAGE_SERVER_PORT     镜像库端口
#IMAGE_SERVER_USERNAME 镜像库账户
#IMAGE_SERVER_PASSWORD 镜像库密码
if [ $_BUILD == "yes" ]; then
    source $APP_ROOT/bin/ant.sh \
    --ANT_ROOT=$ANT_ROOT \
    --TYPE=$type \
    --DIR_NAME=$name \
    --CONTEXT=$_CONTEXT \
    --APP_CONF=$_APP_CONF \
    --BUILD_SERVER_IP=$_BUILD_SERVER_IP \
    --BUILD_SERVER_PORT=$_BUILD_SERVER_PORT \
    --BUILD_SERVER_USERNAME=$_BUILD_SERVER_USERNAME \
    --BUILD_SERVER_PASSWORD=$_BUILD_SERVER_PASSWORD \
    --PROJECTPORT=$projectPort \
    --GIT_TAG=$_GIT_TAG \
    --IMAGE_SERVER_IP=$_IMAGE_SERVER_IP \
    --IMAGE_SERVER_PORT=$_IMAGE_SERVER_PORT \
    --IMAGE_SERVER_USERNAME=$_IMAGE_SERVER_USERNAME \
    --IMAGE_SERVER_PASSWORD=$_IMAGE_SERVER_PASSWORD
fi

#生成yaml(待优化)
#模板临时保存的目录,根据环境的选择
templater_pods=$APP_ROOT/yaml_k8s/${_CONTEXT}/${k8sNamespace}_${k8sName}_deployment.yaml
templater_update=$APP_ROOT/yaml_k8s/${_CONTEXT}/${k8sNamespace}_${k8sName}_deployment_update.json
templater_service=$APP_ROOT/yaml_k8s/${_CONTEXT}/${k8sNamespace}_${k8sName}_service.yaml

#${_APP_CONF},根据 --_APP_CONF参数选定构建应用发布的yaml模板
#输出命令
echo \cp $APP_ROOT/yaml/pods_${type}_${_APP_CONF}.yaml $templater_pods
echo \cp $APP_ROOT/yaml/service_${_APP_CONF}.yaml $templater_service
#执行命令
\cp $APP_ROOT/yaml/pods_${type}_${_APP_CONF}.yaml $templater_pods
\cp $APP_ROOT/yaml/service_${_APP_CONF}.yaml $templater_service

#替换数据

#pods
if [ $_IMAGE_SERVER_PORT == "0" ]; then
    pods_image=$_IMAGE_SERVER_IP/$name:$_GIT_TAG
else
    pods_image=$_IMAGE_SERVER_IP:$_IMAGE_SERVER_PORT/$name:$_GIT_TAG
fi

tmp_heap=$(echo | awk "{print $_MEMORY*0.6}" | awk '{printf ("%.0f\n",$1)}')

sed -i "s|{api-version}|${_API_VERSION}|g" $templater_pods
sed -i "s|{project}|${k8sName}|g" $templater_pods
sed -i "s|{namespace}|${k8sNamespace}|g" $templater_pods
sed -i "s|{projectPort}|${projectPort}|g" $templater_pods
sed -i "s|{version}|${_GIT_TAG}|g" $templater_pods
sed -i "s|{tagName}|51ykb.com|g" $templater_pods
sed -i "s|{node}|${node}|g" $templater_pods
sed -i "s|{img}|${pods_image}|g" $templater_pods
sed -i "s|{cpu}|${_CPU}m|g" $templater_pods
sed -i "s|{memory}|${_MEMORY}Mi|g" $templater_pods
sed -i "s|{heap}|${tmp_heap}m|g" $templater_pods
sed -i "s|{k8sWorkingCheck}|${k8sWorkingCheck}|g" $templater_pods
sed -i "s|{registryKey}|${registryKey}|g" $templater_pods
sed -i "s|{configVolume}|/data/server/${name}/config|g" $templater_pods
sed -i "s|{name}|${name}|g" $templater_pods

#service
tmp_ckPort=$(echo | awk "{print $projectPort+10000}" | awk '{printf ("%.0f\n",$1)}')

sed -i "s|{project}|${k8sName}|g" $templater_service
sed -i "s|{namespace}|${k8sNamespace}|g" $templater_service
sed -i "s|{version}|${_GIT_TAG}|g" $templater_service
sed -i "s|{portip}|${_K8S_INGRESS_IPS}|g" $templater_service
sed -i "s|{port}|${projectPort}|g" $templater_service
sed -i "s|{ckPort}|${tmp_ckPort}|g" $templater_service

#pods update
echo '{"spec":{"template":{"spec":{"containers":[{"name":"'$k8sName'","image":"'$pods_image'"}]}}}}' > $templater_update

#发布发布应用(待优化)
if [ $_RELEASE_MODE == "new" ]; then
    #删除pods
    curl -k -X DELETE -H "Authorization:Bearer ${_K8S_API_TOKEN}" \
    -H "Content-Type: application/yaml" \
    -T "${APP_ROOT}/yaml_k8s/del.yaml" \
    $_K8S_API_IP/apis/$_API_VERSION/namespaces/$k8sNamespace/deployments/$k8sName

    #删除service
    curl -k -X DELETE -H "Authorization:Bearer ${_K8S_API_TOKEN}" \
    -H "Content-Type: application/yaml" \
    -T "${APP_ROOT}/yaml_k8s/del.yaml" \
    $_K8S_API_IP/api/v1/namespaces/$k8sNamespace/services/$k8sName

    #发布pods
    curl -k -X POST -H "Authorization:Bearer ${_K8S_API_TOKEN}" \
    -H "Content-Type: application/yaml" \
    -T "$templater_pods" \
    $_K8S_API_IP/apis/$_API_VERSION/namespaces/$k8sNamespace/deployments

    #发布service
    curl -k -X POST -H "Authorization:Bearer ${_K8S_API_TOKEN}" \
    -H "Content-Type: application/yaml" \
    -T "$templater_service" \
    $_K8S_API_IP/api/v1/namespaces/$k8sNamespace/services
fi

#更新image
if [ $_RELEASE_MODE == "update" ]; then
    curl -k -X PATCH -H "Authorization:Bearer ${_K8S_API_TOKEN}" \
    -H "Content-Type: application/strategic-merge-patch+json" \
    -T "$templater_update" \
    $_K8S_API_IP/apis/$_API_VERSION/namespaces/$k8sNamespace/deployments/$k8sName
fi

#输出kubectl 更新命令
echo
echo
echo
echo
echo $_PROJECT_NAME
echo ["kubectl set image deployment/$k8sName $k8sName=$pods_image -n $k8sNamespace --record=true"]
echo
echo
echo
echo
echo
