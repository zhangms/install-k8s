#!/bin/bash


./reset-env.sh
./install-kubelet.sh $1 $2
./install-kube-proxy.sh $1 $2
