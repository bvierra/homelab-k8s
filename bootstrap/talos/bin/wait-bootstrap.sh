#!/usr/bin/env bash

while ! nc -nzv 10.10.130.101 6443 > /dev/null 2>&1; do
  echo "Waiting for Kubernetes API server to be available..."
  sleep 1
done

task kubeconfig
while [ "$(kubectl get nodes --no-headers 2>/dev/null | wc -l)" -lt 1 ]; do
  echo "Waiting for at least one node to register with the cluster..."
  sleep 1
done

