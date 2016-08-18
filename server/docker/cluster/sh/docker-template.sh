#!/bin/bash
#
# Docker模板管理脚本
#
mntDocker=/mnt/hgfs/workfiles/docker
nodeName="cluster${i}"
case "$1" in
    bridge )
        ip addr add 192.168.163.131/24 dev br0;
        ip addr del 192.168.163.131/24 dev eth0;
        brctl addif br0 eth0;
        route del default;
        route add default gw 192.168.163.2 dev br0
        ifconfig
    ;;
    create )
        nodeName="cluster${i}"
        echo "create ${nodeName}...";
        docker create --name ${nodeName} --hostname ${nodeName} -v ${mntDocker}/cluster/data/${nodeName}:/data -P iisquare/cluster
        docker ps -a
    ;;
    start )
        echo "start ${nodeName}...";
        docker start ${nodeName}
        /opt/pipework/pipework br0 ${nodeName} 192.168.163.100/24@192.168.163.2
        docker ps
    ;;
    stop )
        echo "stop ${nodeName}...";
        docker stop ${nodeName}        
        docker ps 
    ;;
    rm )
        echo "rm ${nodeName}...";
        docker rm ${nodeName}        
        docker ps 
    ;;
    commit )
        if [ "$2" ]; then
            echo "commit ${nodeName}...";
            docker commit ${2} iisquare/cluster
        else
            docker ps
            echo "Usage: commit CONTAINER_ID";
        fi
    ;;
    * )
        echo "Usage: [bridge|create|start|stop|rm|commit]";
    ;;
esac

