#!/bin/bash
#
# Docker容器管理脚本
#
nodeCount=6
mntDocker=/mnt/hgfs/workfiles/docker
case "$1" in
    create )
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            echo "create ${nodeName}...";
            docker create --name ${nodeName} --hostname ${nodeName} -v ${mntDocker}/cluster/data/${nodeName}:/data -P iisquare/cluster
        done
        docker ps -a
    ;;
    start|restart )
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            echo "${1} ${nodeName}...";
            docker ${1} ${nodeName}
            /opt/pipework/pipework br0 ${nodeName} 192.168.163.10${i}/24@192.168.163.2
        done
        docker ps
    ;;
    stop )
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            echo "stop ${nodeName}...";
            docker stop ${nodeName}        
        done
        docker ps 
    ;;
    rm )
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            echo "rm ${nodeName}...";
            docker rm ${nodeName}        
        done
        docker ps 
    ;;
    * )
        echo "Usage: [create|start|stop|restart|rm]";
    ;;
esac

