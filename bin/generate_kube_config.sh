#!/bin/bash

set -ex

IP=$(ifconfig|grep en0 -a2|grep inet|cut -d\  -f2)

if [[ ! -f conf/admin.kubeconfig ]]; then
    # Setup kubelet kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://${IP}:6443 \
    --kubeconfig=conf/kubelet.kubeconfig

    kubectl config set-credentials system:node:${instance} \
    --client-certificate=certs/kubelet.pem \
    --client-key=certs/kubelet-key.pem \
    --embed-certs=true \
    --kubeconfig=conf/kubelet.kubeconfig

    kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:kubelet \
    --kubeconfig=conf/kubelet.kubeconfig

    kubectl config use-context default --kubeconfig=conf/kubelet.kubeconfig

    # Setup kube-proxy kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://${IP}:6443 \
    --kubeconfig=conf/kube-proxy.kubeconfig

    kubectl config set-credentials system:kube-proxy \
    --client-certificate=certs/kube-proxy.pem \
    --client-key=certs/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=conf/kube-proxy.kubeconfig

    kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=conf/kube-proxy.kubeconfig

    kubectl config use-context default --kubeconfig=conf/kube-proxy.kubeconfig

    # Setup controller manager kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=conf/kube-controller-manager.kubeconfig

    kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=certs/kube-controller-manager.pem \
    --client-key=certs/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=conf/kube-controller-manager.kubeconfig

    kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=conf/kube-controller-manager.kubeconfig

    kubectl config use-context default --kubeconfig=conf/kube-controller-manager.kubeconfig

    # Setup scheduler kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=conf/kube-scheduler.kubeconfig

    kubectl config set-credentials system:kube-scheduler \
    --client-certificate=certs/kube-scheduler.pem \
    --client-key=certs/kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=conf/kube-scheduler.kubeconfig

    kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=conf/kube-scheduler.kubeconfig

    kubectl config use-context default --kubeconfig=conf/kube-scheduler.kubeconfig

    # Setup admin kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=certs/ca.pem \
        --embed-certs=true \
        --server=https://127.0.0.1:6443 \
        --kubeconfig=conf/admin.kubeconfig

    kubectl config set-credentials admin \
        --client-certificate=certs/admin.pem \
        --client-key=certs/admin-key.pem \
        --embed-certs=true \
        --kubeconfig=conf/admin.kubeconfig

    kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=admin \
        --kubeconfig=conf/admin.kubeconfig

    kubectl config use-context default --kubeconfig=conf/admin.kubeconfig
fi