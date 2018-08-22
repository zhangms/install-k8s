#!/bin/bash

kube_master_ip=$1
kube_master_port=$2

serviceName=kubelet

function createServiceFile() {
    str="[Unit]\n
         Description=Kubernetes Kubelet Server\n
         After=docker.service\n
         Requires=docker.service\n\n
         [Service]\n
         WorkingDirectory=/var/lib/kubelet\n
         EnvironmentFile=-/etc/kubernetes/config\n
         EnvironmentFile=-/etc/kubernetes/kubelet\n
         ExecStart=/usr/local/bin/kubelet \$KUBE_BASE_OPTIONS \$KUBELET_OPTIONS\n
         Restart=on-failure\n\n
         [Install]\n
         WantedBy=multi-user.target\n"
    echo -e $str > /usr/lib/systemd/system/${serviceName}.service
}

function createServiceConfig() {
    mkdir /etc/kubernetes/
    base_config='KUBELET_OPTIONS="'
    base_config+=' --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1'
    base_config+=' --cluster-dns=10.254.0.2'
    base_config+=' --kubeconfig=/etc/kubernetes/kubeconfig'
    base_config+=' --runtime-cgroups=/systemd/system.slice'
    base_config+=' --kubelet-cgroups=/systemd/system.slice'
    base_config+=' --enable-server=true'
    base_config+=' --enable-debugging-handlers=true'
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/kubelet
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

