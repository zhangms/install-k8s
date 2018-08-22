#!/bin/bash
./reset-env.sh $1 $2
./install-etcd-service.sh
./install-kube-apiserver-service.sh $1 $2
./install-kube-controller-manager-service.sh $1 $2
./install-kube-scheduler-service.sh $1 $2
