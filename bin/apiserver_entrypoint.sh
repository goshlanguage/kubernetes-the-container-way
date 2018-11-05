#!/bin/sh

set -e

# use ip over ifconfig since ifconfig is unavailable in hyperkube
# grep "inet " to avoid globbing on ipv6 addresses
IP=$(ip -4 a show dev eth0|grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"|head -1)
CIDR=$(echo ${IP}|awk -F\. '{print $1"."$2"."$3".0/24"}')

kube-apiserver \
        --etcd-servers "https://etcd-0:2379" \
        --advertise-address="${IP}" \
        --allow-privileged=true \
        --apiserver-count=1 \
        --audit-log-maxage=30 \
        --audit-log-maxbackup=3 \
        --audit-log-maxsize=100 \
        --audit-log-path=/var/log/audit.log \
        --authorization-mode=Node,RBAC \
        --bind-address=0.0.0.0 \
        --client-ca-file=/certs/ca.pem \
        --enable-admission-plugins=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
        --enable-swagger-ui=true \
        --etcd-cafile=/certs/ca.pem \
        --etcd-certfile=/certs/etcd.pem \
        --etcd-keyfile=/certs/etcd-key.pem \
        --etcd-servers=https://etcd-0:2380 \
        --event-ttl=1h \
        --experimental-encryption-provider-config=/conf/encryption-config.yaml \
        --kubelet-certificate-authority=/certs/ca.pem \
        --kubelet-client-certificate=/certs/kubernetes.pem \
        --kubelet-client-key=/certs/kubernetes-key.pem \
        --kubelet-https=true \
        --runtime-config=api/all \
        --service-account-key-file=/certs/service-account.pem \
        --service-cluster-ip-range=${CIDR} \
        --service-node-port-range=30000-32767 \
        --tls-cert-file=/certs/kubernetes.pem \
        --tls-private-key-file=/certs/kubernetes-key.pem \
        --v=2