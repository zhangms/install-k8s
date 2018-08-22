
#kubernetes各组件需要使用TLS证书对通信进行加密，这里我使用CloudFlare的PKI工具集 cfssl 来生成CA和其它证书。
#
#生成的CA证书和密钥文件如下：
#
#ca-key.pem
#ca.pem
#kubernetes-key.pem
#kubernetes.pem
#kube-proxy.pem
#kube-proxy-key.pem
#admin.pem
#admin-key.pem
#各组件使用证书的情况如下：
#
#etcd：使用ca.pem、kubernetes-key.pem、kubernetes.pem；
#kube-apiserver：使用ca.pem、kubernetes-key.pem、kubernetes.pem；
#kubelet：使用ca.pem；
#kube-proxy：使用ca.pem、kube-proxy-key.pem、kube-proxy.pem；
#kubectl：使用ca.pem、admin-key.pem、admin.pem
#kube-controller、kube-scheduler当前需要和kube-apiserver部署在同一台机器上且使用非安全端口通信，故不需要证书

#!/bin/bash


#证书存放目录
SSL_DIR=/etc/kubernetes/ssl
#SSL_DIR=/Users/ZMS/Downloads/ssl

#集群节点
CLUSTER_HOSTS=$(cat ./cluster_host.txt)

#初始化
init() {
   rm -rf ${SSL_DIR}
   mkdir -p ${SSL_DIR}
}

create_ca_config_json() {
cat <<EOF > ${SSL_DIR}/ca-config.json
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF
}

create_ca_csr_json() {
cat <<EOF > ${SSL_DIR}/ca-csr.json
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
}

create_ca_csr() {
    echo "创建CA证书..."
    #创建配置文件
    create_ca_config_json
    create_ca_csr_json
    #创建CA证书
    cfssl gencert -initca ${SSL_DIR}/ca-csr.json | cfssljson -bare ${SSL_DIR}/ca
}

create_kubernetes_csr_json() {
cat <<EOF > ${SSL_DIR}/kubernetes-csr.json
{
    "CN": "kubernetes",
    "hosts": [
      "127.0.0.1",
      ${CLUSTER_HOSTS}
      "10.254.0.1",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "BeiJing",
            "L": "BeiJing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
}

create_kubernetes_csr() {
    echo "生成 kubernetes 证书和私钥..."
    #创建配置文件
    create_kubernetes_csr_json
    cfssl gencert -ca=${SSL_DIR}/ca.pem -ca-key=${SSL_DIR}/ca-key.pem \
         -config=${SSL_DIR}/ca-config.json \
         -profile=kubernetes ${SSL_DIR}/kubernetes-csr.json | cfssljson -bare ${SSL_DIR}/kubernetes
}


create_admin_csr_json() {
cat <<EOF > ${SSL_DIR}/admin-csr.json
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
}

create_admin_csr() {
   echo "生成admin证书和私钥..."
   create_admin_csr_json
   cfssl gencert -ca=${SSL_DIR}/ca.pem -ca-key=${SSL_DIR}/ca-key.pem \
        -config=${SSL_DIR}/ca-config.json \
        -profile=kubernetes ${SSL_DIR}/admin-csr.json | cfssljson -bare ${SSL_DIR}/admin
}

create_kube_proxy_csr_json() {
cat <<EOF > ${SSL_DIR}/kube-proxy-csr.json
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
}

create_kube_proxy_csr(){
    echo "生成kube-proxy证书和私钥..."
    create_kube_proxy_csr_json
    cfssl gencert -ca=${SSL_DIR}/ca.pem -ca-key=${SSL_DIR}/ca-key.pem \
         -config=${SSL_DIR}/ca-config.json \
         -profile=kubernetes  ${SSL_DIR}/kube-proxy-csr.json | cfssljson -bare ${SSL_DIR}/kube-proxy
}

validate_kubernetes_pem() {
    echo "校验Kubernetes证书..."
    openssl x509 -noout -text -in ${SSL_DIR}/kubernetes.pem
}

do_create() {
   init
   create_ca_csr
   create_kubernetes_csr
   create_admin_csr
   create_kube_proxy_csr
   validate_kubernetes_pem
   echo "证书生成完毕..."
}

do_create