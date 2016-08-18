#!/bin/bash
#
# 集群服务管理脚本
#
sshCmd() # 执行远程Shell
{
    ssh -p 22 root@${1} "${2}"
}

zookeeper()
{
    local nodeCount=5
    local serverDir=/opt/zookeeper-3.4.8
    if [ "${2}" ]; then
        local i
        for((i=1; i<=${nodeCount}; i++))
        do
            local nodeName="cluster${i}"
            echo "${2} ${nodeName}.${1}..."
            sshCmd ${nodeName} "${serverDir}/bin/zkServer.sh ${2}"
        done
    else
        echo "Usage: ${1} [start|stop|restart|status]"
    fi
}

tomcat()
{
    local nodeCount=6
    local serverDir=/opt/apache-tomcat-7.0.65
}

if [ "${1}"  ];then
    $1 $*
else
    echo "Usage: serverName serverOptions"
fi

