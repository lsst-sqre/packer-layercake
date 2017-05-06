#!/bin/bash

set -o errexit

ARGS=()

if [ ! -z "$TAG" ]; then
  ARGS+=('-t')
  ARGS+=("$TAG")
fi
ARGS+=("$PRODUCTS")

source ${STACK_PATH}/loadLSST.bash;
eups distrib install "${ARGS[@]}"
