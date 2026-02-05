#!/usr/bin/env bash


gencommand_worker=$(talhelper gencommand reset --extra-flags="--graceful=false --reboot=true --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL" | grep 130.11)
gencommand_cp=$(talhelper gencommand reset --extra-flags="--graceful=false --reboot=true --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL" | grep 130.10)

echo "Worker Nodes:"
while IFS= read -r line; do
  eval "$line" &
done <<< "$gencommand_worker"

wait

echo "CP Nodes:"
while IFS= read -r line; do
  eval "$line" &
done <<< "$gencommand_cp"

wait

echo "Cleaning up config files..."
rm -rf clusterconfig/
rm -f "${HOME}/.kube/config"
rm -f "${HOME}/.talos/config"
