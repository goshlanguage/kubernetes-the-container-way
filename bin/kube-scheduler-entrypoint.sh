#!/bin/sh

set -e

kube-scheduler \
        --config=/conf/kube-scheduler.yaml \
        --v=2