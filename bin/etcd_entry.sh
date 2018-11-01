#!/bin/sh

# grep "inet " to avoid globbing on ipv6 addresses
IP=$(ifconfig eth0|grep "inet "|cut -d: -f2|cut -d\  -f1)
ETCD_NAME=$(hostname -s)

etcd --name ${ETCD_NAME} \
  --initial-advertise-peer-urls http://${IP}:2380 \
  --listen-peer-urls http://${IP}:2380 \
  --listen-client-urls http://${IP}:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://${IP}:2379 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
