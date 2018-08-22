#!/bin/bash

kube_master_ip=$1
kube_master_port=$2

serviceName=kube-scheduler

function createServiceFile() {
    str="[Unit]\n
         Description=Kubernetes Scheduler Plugin\n\n
         [Service]\n
         EnvironmentFile=-/etc/kubernetes/config\n
         EnvironmentFile=-/etc/kubernetes/scheduler\n
         ExecStart=/usr/local/bin/kube-scheduler \$KUBE_BASE_OPTIONS \$KUBE_SCHEDULER_OPTIONS\n
         Restart=on-failure\n
         LimitNOFILE=65536\n\n
         [Install]\n
         WantedBy=multi-user.target\n"
    echo -e $str > /usr/lib/systemd/system/${serviceName}.service
}

function createServiceConfig() {

    mkdir /etc/kubernetes/

    base_config='KUBE_SCHEDULER_OPTIONS="'
    base_config+=' --kubeconfig=/etc/kubernetes/kubeconfig'
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/scheduler
}

function createConfigFile() {
    createServiceConfig
}

createServiceFile
createConfigFile
systemctl daemon-reload
systemctl disable ${serviceName}
systemctl enable ${serviceName}
systemctl restart ${serviceName}
systemctl status ${serviceName}

