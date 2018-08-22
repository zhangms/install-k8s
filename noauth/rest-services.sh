#!/bin/bash

systemctl disable etcd
systemctl stop etcd

systemctl disable kube-apiserver
systemctl stop kube-apiserver

systemctl disable kube-controller-manager
systemctl stop kube-controller-manager

systemctl disable kube-scheduler
systemctl stop kube-scheduler

systemctl disable kubelet
systemctl stop kubelet

systemctl disable kube-proxy
systemctl stop kube-proxy
