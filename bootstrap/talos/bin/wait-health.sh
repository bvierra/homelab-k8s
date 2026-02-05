#!/usr/bin/env bash

while ! talhelper gencommand health | bash; do
  echo "Waiting for Talos to become healthy..."
  sleep 1
done
