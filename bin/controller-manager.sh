#!/bin/sh

set -e

IP=$(ip -4 a show dev eth0|grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"|head -1)
CIDR=$(echo ${IP}|awk -F\. '{print $1"."$2"."$3".0/24"}')

# For more information about the kube-controller-manager command line interface see:
#   https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/

kube-controller-manager \
  --cluster-cidr=${CIDR}/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/certs/ca.pem \
  --cluster-signing-key-file=/certs/ca-key.pem \
  --kubeconfig=/conf/kube-controller-manager.yaml \
  --leader-elect=true \
  --root-ca-file=/certs/ca.pem \
  --service-account-private-key-file=/certs/service-account-key.pem \
  --service-cluster-ip-range=${CIDR}/24 \
  --use-service-account-credentials=true \
  --v=2
