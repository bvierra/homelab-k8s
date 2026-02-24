#!/usr/bin/env bash

shopt -s globstar

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(readlink -f "$SCRIPT_DIR"/..)

[ -f test.yaml ] && rm test.yaml

find manifests/apps/ -type d -name "base" -print0 | while IFS= read -r -d $'\0' dir; do
  if [[ -f "$dir/kustomization.yaml" || -f "$dir/kustomization.yml" ]]; then
    echo "INFO - Testing kustomize build for $dir"
    kustomize build "$dir" | yq ea -e 'select(.kind == "OCIRepository")' >> test.yaml
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
      echo "ERROR - Kustomize build failed for $dir"
      exit 1
    else
      echo "---" >> test.yaml
      echo "INFO - Kustomize build succeeded for $dir"
    fi
  fi
done
