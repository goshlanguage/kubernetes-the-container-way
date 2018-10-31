#!/bin/sh

# grep "inet " to avoid globbing on ipv6 addresses
IP=$(ifconfig eth0|grep "inet "|cut -d: -f2|cut -d\  -f1)
ETCD_NAME=$(hostname -s)

etcd --name ${ETCD_NAME} \
  --cert-file=/certs/kubernetes.pem \
  --key-file=/certs/kubernetes-key.pem \
  --peer-cert-file=/certs/kubernetes.pem \
  --peer-key-file=/certs/kubernetes-key.pem \
  --trusted-ca-file=/certs/ca.pem \
  --peer-trusted-ca-file=/certs/ca.pem \
  --peer-client-cert-auth \
  --initial-advertise-peer-urls https://${IP}:2380 \
  --listen-peer-urls https://${IP}:2380 \
  --listen-client-urls https://${IP}:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://${IP}:2379 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd \
  --debug \
  --force-new-cluster
