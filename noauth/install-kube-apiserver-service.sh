#!/bin/bash

kube_master_ip=$1
kube_master_port=$2

function create_serviceFile() {
    serviceFile="/usr/lib/systemd/system/kube-apiserver.service"
    str="[Unit]\n
         Description=Kubernetes API Service\n
         After=network.target\n
         After=etcd.service\n\n
         [Service]\n
         EnvironmentFile=-/etc/kubernetes/config\n
         EnvironmentFile=-/etc/kubernetes/apiserver\n
         ExecStart=/usr/local/bin/kube-apiserver '${KUBE_BASE_OPTIONS} ${KUBE_API_OPTIONS}'\n
         Restart=on-failure\n
         Type=notify\n
         LimitNOFILE=65536\n\n
         [Install]\n
         WantedBy=multi-user.target\n"
    echo -e $str > $serviceFile
}

function createBaseConfig() {

    mkdir /etc/kubernetes/
    mkdir /var/log/kubernetes/

    base_config='KUBE_BASE_OPTIONS="'
    base_config+='--logtostderr=true --log-dir=/var/log/kubernetes --v=2'
    base_config+='"\n'
    base_config+='KUBE_MASTER="http://'
    base_config+=$kube_master_ip:$kube_master_port
    base_config+='"\n'

    echo -e $base_config > /etc/kubernetes/config
}

function createServiceConfig() {

    mkdir /etc/kubernetes/

    base_config='KUBE_API_OPTIONS="'
    base_config+='--bind-address='$kube_master_ip' '
    base_config+='--secure-port='$kube_master_port' '
    base_config+='--anonymous-auth=true '
    base_config+='--authorization-mode=AlwaysAllow '
    base_config+='--etcd-servers=http://127.0.0.1:2379 '
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/apiserver
}

function createConfigFile() {
    createBaseConfig
    createServiceConfig
}

create_serviceFile
createConfigFile
systemctl daemon-reload
systemctl disable kube-apiserver
systemctl enable kube-apiserver
systemctl restart kube-apiserver
systemctl status kube-apiserver

