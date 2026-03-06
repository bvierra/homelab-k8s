#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(readlink -f "$SCRIPT_DIR"/..)
DEF_CILIUM_CONFIG_DIR="${ROOT_DIR}/../../../homelab-k8s/manifests/apps/kube-system/cilium-config/base/"

CILIUM_CONFIG_DIR=${CILIUM_CONFIG_DIR:-${DEF_CILIUM_CONFIG_DIR}}

until kubectl get crd ciliumbgpadvertisements.cilium.io >/dev/null 2>&1; do
  echo "INFO - Waiting for Cilium CRDs to be available..."
  sleep 5
done

for file in "$CILIUM_CONFIG_DIR"/*.yaml; do
  [[ "$file" =~ kustomization.yaml$ ]] && continue
  file=$(readlink -f "$file")
  echo "INFO - Applying $file..."
  while ! kubectl apply -f "$file"; do
    sleep 5
  done
done
