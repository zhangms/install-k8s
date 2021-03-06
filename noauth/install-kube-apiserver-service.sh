#!/bin/bash

kube_master_ip=$1
kube_master_port=$2

serviceName=kube-apiserver

function createServiceFile() {
    str="[Unit]\n
         Description=Kubernetes API Service\n
         After=network.target\n
         After=etcd.service\n\n
         [Service]\n
         EnvironmentFile=-/etc/kubernetes/config\n
         EnvironmentFile=-/etc/kubernetes/apiserver\n
         ExecStart=/usr/local/bin/kube-apiserver \$KUBE_BASE_OPTIONS \$KUBE_API_OPTIONS\n
         Restart=on-failure\n
         Type=notify\n
         LimitNOFILE=65536\n\n
         [Install]\n
         WantedBy=multi-user.target\n"
    echo -e $str > /usr/lib/systemd/system/${serviceName}.service
}

function createTokenAuthFile() {
    echo "token_admin,admin,1" > /etc/kubernetes/token-auth-file
}

function createServiceConfig() {
    mkdir /etc/kubernetes/
    base_config='KUBE_API_OPTIONS="'
    base_config+=' --bind-address=0.0.0.0'
    base_config+=' --secure-port='$kube_master_port
    base_config+=' --insecure-port=0'
    base_config+=' --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota'
    base_config+=' --etcd-servers=http://127.0.0.1:2379'
    base_config+=' --authorization-mode=Node,RBAC'
    base_config+=' --token-auth-file=/etc/kubernetes/token-auth-file'
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/apiserver
}

function createConfigFile() {
    createServiceConfig
    createTokenAuthFile
}

createServiceFile
createConfigFile
systemctl daemon-reload
systemctl disable ${serviceName}
systemctl enable ${serviceName}
systemctl restart ${serviceName}
systemctl status ${serviceName}

