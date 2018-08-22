#!/usr/bin/env bash

KUBE_APISERVER=$1
KUBE_APISERVER_PORT=$2

KUBE_CFG_DIR=/etc/kubernetes
SSL_DIR=${KUBE_CFG_DIR}/ssl

#删除旧配置
rm -rf ${HOME}/.kube/*

# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=${SSL_DIR}/ca.pem \
  --embed-certs=true \
  --server=https://${KUBE_APISERVER}:${KUBE_APISERVER_PORT}


# 设置客户端认证参数
kubectl config set-credentials admin \
  --client-certificate=${SSL_DIR}/admin.pem \
  --embed-certs=true \
  --client-key=${SSL_DIR}/admin-key.pem

# 设置上下文参数
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin

# 设置默认上下文
kubectl config use-context kubernetes

# 拷贝配置文件
rm -rf ${KUBE_CFG_DIR}/kubeconfig
cp ${HOME}/.kube/config ${KUBE_CFG_DIR}/kubeconfig

echo "kubeconfig配置完毕..."
