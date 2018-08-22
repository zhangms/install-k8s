#!/bin/bash

kube_master_ip=$1
kube_master_port=$2

serviceName=kube-proxy

function createServiceFile() {
    str="[Unit]\n
         Description=Kubernetes Kube-Proxy Server\n
         After=network.target\n\n
         [Service]\n
         EnvironmentFile=-/etc/kubernetes/config\n
         EnvironmentFile=-/etc/kubernetes/proxy\n
         ExecStart=/usr/local/bin/kube-proxy \$KUBE_BASE_OPTIONS \$KUBE_PROXY_OPTIONS \n
         Restart=on-failure\n
         LimitNOFILE=65536\n\n
         [Install]\n
         WantedBy=multi-user.target\n"
    echo -e $str > /usr/lib/systemd/system/${serviceName}.service
}

function createServiceConfig() {
    mkdir /etc/kubernetes/
    base_config='KUBE_PROXY_OPTIONS="'
    base_config+=' --kubeconfig=/etc/kubernetes/kubeconfig'
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/proxy
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

