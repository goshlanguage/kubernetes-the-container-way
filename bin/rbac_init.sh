#!/bin/bash

set -ex

kubectl --kubeconfig ./kubeconfig/admin.yaml apply ./conf/rbac-kube-apiserver-to-kubelet-ClusterRole.yaml
kubectl --kubeconfig ./kubeconfig/admin.yaml apply ./conf/rbac-kubernetes-user.yaml