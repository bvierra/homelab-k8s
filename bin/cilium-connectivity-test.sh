#!/usr/bin/env bash

# This is only here due to: https://github.com/cilium/cilium-cli/issues/3173

NAMESPACES=(cilium-test-1 cilium-test-ccnp1 cilium-test-ccnp2)
for ns in "${NAMESPACES[@]}"; do
  if kubectl get ns "$ns" &>/dev/null; then
    echo "Namespace $ns already exists, deleting it first..."
    kubectl delete namespace "$ns"
  fi
  until kubectl create ns "$ns"; do
    echo "Failed to create namespace $ns, retrying in 5 seconds..."
    sleep 5
  done
  kubectl label ns "$ns" "pod-security.kubernetes.io/enforce=privileged" "pod-security.kubernetes.io/audit=privileged" "pod-security.kubernetes.io/warn=privileged"
done

cilium connectivity test

sleep 30

for ns in "${NAMESPACES[@]}"; do
  echo "Checking connectivity test results for namespace $ns..."
  kubectl delete namespace "$ns"
done
