#!/bin/bash

if ! command -v openssl &> /dev/null
then
    echo "openssl could not be found, please install it."
    exit 1
fi
echo Garage Key Generator
echo id: GK$(openssl rand -hex 12)
echo secret: $(openssl rand -hex 32)