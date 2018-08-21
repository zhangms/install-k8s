#!/bin/bash

kube_master_ip=$1
kube_master_port=$2

serviceName=kube-controller-manager

function create_serviceFile() {
    str="[Unit]\n
         Description=Kubernetes Controller Manager\n\n
         [Service]\n
         EnvironmentFile=-/etc/kubernetes/config\n
         EnvironmentFile=-/etc/kubernetes/controller-manager\n
         ExecStart=/usr/local/bin/kube-controller-manager \$KUBE_MASTER \$KUBE_BASE_OPTIONS \$KUBE_CONTROLLER_OPTIONS\n
         Restart=on-failure\n
         LimitNOFILE=65536\n\n
         [Install]\n
         WantedBy=multi-user.target\n"
    echo -e $str > /usr/lib/systemd/system/${serviceName}.service
}

function createBaseConfig() {

    mkdir /etc/kubernetes/
    mkdir /var/log/kubernetes/

    base_config='KUBE_BASE_OPTIONS="'
    base_config+='--logtostderr=true --log-dir=/var/log/kubernetes --v=2'
    base_config+='"\n'
    base_config+='KUBE_MASTER="--master=http://'
    base_config+=$kube_master_ip:$kube_master_port
    base_config+='"\n'

    echo -e $base_config > /etc/kubernetes/config
}

function createServiceConfig() {

    mkdir /etc/kubernetes/

    base_config='KUBE_CONTROLLER_OPTIONS="'
    base_config+='--service-cluster-ip-range=10.254.0.0/16 '
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/controller-manager
}

function createConfigFile() {
    createBaseConfig
    createServiceConfig
}

create_serviceFile
createConfigFile
systemctl daemon-reload
systemctl disable ${serviceName}
systemctl enable ${serviceName}
systemctl restart ${serviceName}
systemctl status ${serviceName}

