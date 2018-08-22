#!/bin/bash
./reset-env.sh $1 $2
./install-kubelet.sh $1 $2
./install-kube-proxy.sh $1 $2
