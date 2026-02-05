#!/usr/bin/env bash
# This script verifies that all SOPS-encrypted files in the repository are currently encrypted
# and have not been accidentally committed in plaintext.

shopt -s globstar

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(readlink -f "$SCRIPT_DIR"/..)
DIRS=("$ROOT_DIR/manifests" "$ROOT_DIR/bootstrap")

for dir in "${DIRS[@]}"; do
  echo "Verifying SOPS-encrypted files in directory: $dir"
  unencrypted_files=()

  while IFS= read -r -d '' file; do
    base_name=$(basename "${file}")
    [[ "$base_name" == ".sops.yaml" ]] && continue
    status=$(sops filestatus "$file" | jq -r '.encrypted')
    if [[ $status != "true" ]]; then
      unencrypted_files+=("$file")
    fi
  done < <(find "$dir" -type f \( -name "*.sops.yaml" -o -name "*.sops.yml" -o -name "*.sops.json" \) -print0)

  if [ ${#unencrypted_files[@]} -ne 0 ]; then
    echo "The following SOPS-encrypted files are not properly encrypted:"
    for file in "${unencrypted_files[@]}"; do
      echo "  - $file"
    done
    exit 1
  else
    echo "All SOPS-encrypted files in $dir are properly encrypted."
  fi
done
