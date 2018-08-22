#!/bin/bash

rm -rf ${HOME}/.kube/*
rm -rf /etc/kubernetes/*
rm -rf /var/lib/etcd/*

function createBaseConfig() {

    mkdir /etc/kubernetes/
    mkdir /var/log/kubernetes/

    base_config='KUBE_BASE_OPTIONS="'
    base_config+='--logtostderr=false --log-dir=/var/log/kubernetes --v=2'
    base_config+='"\n'
    base_config+='KUBE_MASTER="--master=https://'
    base_config+=$kube_master_ip:$kube_master_port
    base_config+='"\n'
    echo -e $base_config > /etc/kubernetes/config
}

function createKubeConfig() {
    rm -rf /etc/kubernetes/kubeconfig
    kubectl config set-cluster kubernetes-demo --server=http://${kube_master_ip}:${kube_master_port} --kubeconfig=/etc/kubernetes/kubeconfig
    kubectl config set-credentials admin --token=token_admin --kubeconfig=/etc/kubernetes/kubeconfig
    kubectl config set-context kube-demo-ctx --cluster=kubernetes-demo --user=admin --kubeconfig=/etc/kubernetes/kubeconfig
    kubectl config use-context kube-demo-ctx --kubeconfig=/etc/kubernetes/kubeconfig
}

createBaseConfig
createKubeConfig
