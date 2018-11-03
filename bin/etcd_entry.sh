#!/bin/sh

set -e

# grep "inet " to avoid globbing on ipv6 addresses
IP=$(ifconfig eth0|grep "inet "|cut -d: -f2|cut -d\  -f1)
ETCD_NAME=$(hostname)

etcd --name ${ETCD_NAME} \
  --cert-file=/certs/etcd.pem \
  --key-file=/certs/etcd-key.pem \
  --peer-cert-file=/certs/etcd.pem \
  --peer-key-file=/certs/etcd-key.pem \
  --trusted-ca-file=/certs/ca.pem \
  --peer-trusted-ca-file=/certs/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --listen-client-urls https://${IP}:2379 \
  --advertise-client-urls https://${IP}:2379 \
  --listen-peer-urls https://${IP}:2380 \
  --initial-advertise-peer-urls https://${IP}:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
