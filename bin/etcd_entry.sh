#!/bin/sh

# grep "inet " to avoid globbing on ipv6 addresses
IP=$(ifconfig eth0|grep "inet "|cut -d: -f2|cut -d\  -f1)

etcd --name etcd \
  --cert-file=/certs/kubernetes.pem \
  --key-file=/certs/etcd/kubernetes-key.pem \
  --peer-cert-file=/certs/kubernetes.pem \
  --peer-key-file=/certs/kubernetes-key.pem \
  --trusted-ca-file=/certs/ca.pem \
  --peer-trusted-ca-file=/certs/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://${IP}:2380 \
  --listen-peer-urls https://${IP}:2380 \
  --listen-client-urls https://${IP}:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://${IP}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster controller-0=https://10.240.0.10:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
