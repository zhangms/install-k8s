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
    rm -rf /etc/kubernetes/kubelet.conf
    kubectl config set-cluster kubernetes-demo \
      --server=http://${kube_master_ip}:${kube_master_port} \
      --kubeconfig=/etc/kubernetes/kubelet.conf \
      --insecure-skip-tls-verify=true
}

function createServiceConfig() {
    mkdir /etc/kubernetes/
    base_config='KUBELET_OPTIONS="'
    base_config+='--kubeconfig=/etc/kubernetes/kubelet.conf'
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

