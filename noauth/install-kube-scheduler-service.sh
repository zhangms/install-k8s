#!/bin/bash

kube_master_ip=$1
kube_master_port=$2

serviceName=kube-scheduler

function create_serviceFile() {
    str="[Unit]\n
         Description=Kubernetes Scheduler Plugin\n\n
         [Service]\n
         EnvironmentFile=-/etc/kubernetes/config\n
         EnvironmentFile=-/etc/kubernetes/scheduler\n
         ExecStart=/usr/local/bin/kube-scheduler \$KUBE_MASTER \$KUBE_BASE_OPTIONS \$KUBE_SCHEDULER_OPTIONS\n
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

    base_config='KUBE_SCHEDULER_OPTIONS="'
    base_config+=''
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/scheduler
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

