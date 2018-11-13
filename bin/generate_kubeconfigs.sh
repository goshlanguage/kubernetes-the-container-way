#!/bin/bash

set -ex

# grep "inet " to avoid globbing on ipv6 addresses
IP=$(ifconfig|grep en0 -a2|grep "inet "|cut -d\  -f2)

if [ -z ./kubeconfig/ ]; then
    mkdir -v ./kubeconfig;
fi

if [[ ! -f kubeconfig/admin.yaml ]]; then
    # Setup kubelet kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://kube-apiserver:6443 \
    --kubeconfig=kubeconfig/kubelet.yaml

    kubectl config set-credentials system:node:${instance} \
    --client-certificate=certs/kubelet.pem \
    --client-key=certs/kubelet-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/kubelet.yaml

    kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:kubelet \
    --kubeconfig=kubeconfig/kubelet.yaml

    kubectl config use-context default --kubeconfig=kubeconfig/kubelet.yaml

    # Setup kube-proxy kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://kube-apiserver:6443 \
    --kubeconfig=kubeconfig/kube-proxy.yaml

    kubectl config set-credentials system:kube-proxy \
    --client-certificate=certs/kube-proxy.pem \
    --client-key=certs/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/kube-proxy.yaml

    kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kubeconfig/kube-proxy.yaml

    kubectl config use-context default --kubeconfig=kubeconfig/kube-proxy.yaml

    # Setup controller manager kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://kube-apiserver:6443 \
    --kubeconfig=kubeconfig/kube-controller-manager.yaml

    kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=certs/kube-controller-manager.pem \
    --client-key=certs/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/kube-controller-manager.yaml

    kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kubeconfig/kube-controller-manager.yaml

    kubectl config use-context default --kubeconfig=kubeconfig/kube-controller-manager.yaml

    # Setup scheduler kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://kube-apiserver:6443 \
    --kubeconfig=kubeconfig/kube-scheduler.yaml

    kubectl config set-credentials system:kube-scheduler \
    --client-certificate=certs/kube-scheduler.pem \
    --client-key=certs/kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/kube-scheduler.yaml

    kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kubeconfig/kube-scheduler.yaml

    kubectl config use-context default --kubeconfig=kubeconfig/kube-scheduler.yaml

    # Setup admin kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=certs/ca.pem \
        --embed-certs=true \
        --server=https://127.0.0.1:6443 \
        --kubeconfig=kubeconfig/admin.yaml

    kubectl config set-credentials admin \
        --client-certificate=certs/admin.pem \
        --client-key=certs/admin-key.pem \
        --embed-certs=true \
        --kubeconfig=kubeconfig/admin.yaml

    kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=admin \
        --kubeconfig=kubeconfig/admin.yaml

    kubectl config use-context default --kubeconfig=kubeconfig/admin.yaml
fi