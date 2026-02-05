#!/usr/bin/env bash

# This script creates a ConfigMap YAML file containing Cilium Helm values
# to be used with Talos inline manifests during cluster setup.
# This allows us to use the custom Cilium values that are deployed with flux during bootstrap.
# We cannot use the raw values because it has to be wrapped in a talos inlinemanifests ConfigMap manifest.

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(readlink -f "$SCRIPT_DIR"/..)
DEF_CILIUM_VALUES_FILE="${ROOT_DIR}/../../manifests/apps/kube-system/cilium-operator/base/helm/values.yaml"

CILIUM_VALUES_FILE=${CILIUM_VALUES_FILE:-${DEF_CILIUM_VALUES_FILE}}
CILIUM_CM_OUT=${CILIUM_CM_OUT:-${ROOT_DIR}/patches/cilium-values.yaml}

[ -f "${CILIUM_VALUES_FILE}" ] || { echo "Values file ${CILIUM_VALUES_FILE} not found!"; exit 1; }

[ -f "${CILIUM_CM_OUT}" ] && rm -f "${CILIUM_CM_OUT}"

cat << EOH > "${CILIUM_CM_OUT}"
cluster:
  inlineManifests:
    - name: cilium-values
      contents: |
        ---
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: cilium-values
          namespace: kube-system
        data:
          values.yaml: |-
EOH

while IFS= read -r line; do
  echo "            ${line}" >> "${CILIUM_CM_OUT}"
done < "${CILIUM_VALUES_FILE}"
