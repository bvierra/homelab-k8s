#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")

find "${SCRIPT_DIR}/../clusterconfig/" -type f -name 'k8s-*.yaml' -exec sed -i 's/grubUseUKICmdline: true/grubUseUKICmdline: false/' {} \;
