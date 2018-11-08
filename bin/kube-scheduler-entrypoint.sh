#!/bin/sh

set -e

kube-scheduler \
        --config=/conf/kube-scheduler-config.yaml \
        --v=2