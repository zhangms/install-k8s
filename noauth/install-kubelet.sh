#!/bin/bash

kube_master_ip=$1
kube_master_port=$2

serviceName=kubelet

function create_serviceFile() {
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

function createKubeConfig() {
    rm -rf /etc/kubernetes/kubeconfig
    kubectl config set-cluster kubernetes-demo --server=http://${kube_master_ip}:${kube_master_port} --kubeconfig=/etc/kubernetes/kubeconfig
    kubectl config set-credentials admin --username=admin --kubeconfig=/etc/kubernetes/kubeconfig
    kubectl config set-context kube-demo-ctx --cluster=kubernetes-demo --user=admin --kubeconfig=/etc/kubernetes/kubeconfig
    kubectl config use-context kube-demo-ctx --kubeconfig=/etc/kubernetes/kubeconfig
}

function createServiceConfig() {
    mkdir /etc/kubernetes/
    base_config='KUBELET_OPTIONS="'
    base_config+=' --kubeconfig=/etc/kubernetes/kubeconfig'
    base_config+=' --runtime-cgroups=/systemd/system.slice'
    base_config+=' --kubelet-cgroups=/systemd/system.slice'
    base_config+=' --enable-server=true'
    base_config+=' --enable-debugging-handlers=true'
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/kubelet
}

function createConfigFile() {
    createBaseConfig
    createKubeConfig
    createServiceConfig
}

create_serviceFile
createConfigFile
systemctl daemon-reload
systemctl disable ${serviceName}
systemctl enable ${serviceName}
systemctl restart ${serviceName}
systemctl status ${serviceName}

