#!/bin/sh

set -e

kube-scheduler \
        --config=/kube-scheduler.yaml \
        --v=2