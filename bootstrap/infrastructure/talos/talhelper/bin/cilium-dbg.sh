#!/usr/bin/env bash

declare -a args=("$@")

d=0

command=$(basename "$0" .sh)

if [[ -n $DEBUG && "$DEBUG" -eq 1 ]]; then
  d=1
  echo "DEBUG MODE ENABLED"
fi


if [ ${#args[@]} -lt 1 ]; then
  args+=("--help")
fi

pod=$(kubectl get po -n kube-system | grep cilium | grep -v envoy | grep -v operator | head -n 1 | awk -F' ' '{print $1 }')
if [ $d -eq 1 ]; then
  node=$(kubectl get po "$pod" -o json | jq -r '.spec.nodeName')
  echo "Executing $command in pod: $pod on node: $node"
fi

kubectl exec "pod/${pod}" -n kube-system -- "$command" "${args[@]}"
