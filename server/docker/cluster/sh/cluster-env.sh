#!/bin/bash
#
# 集群环境配置脚本
#
nodeCount=6
password="admin888"
templateDir=$(dirname $0)/template
hostsFile=/etc/hosts
mntDocker=/mnt/hgfs/workfiles/docker

sshExpect() # 自动交互执行远程Shell
{
expect <<EOT
spawn $1
expect {
    "Connection refused" exit
    "Name or service not known" exit
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "$password\r";exp_continue}
    "id_rsa):" {send "\r";exp_continue}
    "(y/n)?" {send "y\r";exp_continue}
}
exit
EOT
}

sshCmd() # 执行远程Shell
{
    ssh -p 22 root@${1} "${2}"
}

case "$1" in
    rsa-generate ) # 重新生成秘钥
        echo "${1} generate ssh-keygen..."
        cat /root/.ssh/id_rsa.pub>${templateDir}/authorized_keys
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            echo "generate ${nodeName}..."
            cmd="ssh -p 22 root@${nodeName} \"cd ~;ssh-keygen -t rsa -P '';cat ~/.ssh/id_rsa.pub\""
            sshExpect "${cmd}"|sed -n "/ssh-rsa/p">>${templateDir}/authorized_keys
        done
        echo "***********authorized_keys***********"
        cat ${templateDir}/authorized_keys
    ;;
    rsa-authorized ) # 拷贝授权文件
        echo "${1} scp authorized_keys..."
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            cmd="scp ${templateDir}/authorized_keys root@${nodeName}:~/.ssh/authorized_keys"
            sshExpect "${cmd}"
        done
    ;;
    hosts ) # 拷贝hosts文件
        echo "${1} scp ${hostsFile}..."
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            cmd="scp ${templateDir}/hosts root@${nodeName}:${hostsFile}"
            sshExpect "${cmd}"
        done
    ;;
    mkdir ) # 创建数据目录
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            echo "${1} ${mntDocker}/cluster/data/${nodeName}/${2}"
            mkdir -p ${mntDocker}/cluster/data/${nodeName}/${2}
        done
    ;;
    touch ) # 创建文件
        for((i=1; i<=${nodeCount}; i++))
        do
            nodeName="cluster${i}"
            echo "${1} ${mntDocker}/cluster/data/${nodeName}/${2}"
            touch ${mntDocker}/cluster/data/${nodeName}/${2}
        done
    ;;
    scp ) # 拷贝hosts文件
        if [ "${2}" -a "${3}" ]; then
            echo "${1} scp ${2} ${3}"
            for((i=1; i<=${nodeCount}; i++))
            do
                nodeName="cluster${i}"
                cmd="scp ${2} root@${nodeName}:${3}"
                sshExpect "${cmd}"
            done
        else
            echo "Usage: scp localFile destFile"
        fi
    ;;
    * )
        echo "Usage: [rsa-generate|rsa-authorized|hosts|mkdir|touch|scp]"
    ;;
esac

