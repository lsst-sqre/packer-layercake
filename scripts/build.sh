#!/bin/bash

set -o errexit

ARGS=()

if [ -n "$TAG" ]; then
  ARGS+=('-t')
  ARGS+=("$TAG")
fi
ARGS+=("$PRODUCTS")

# shellcheck disable=SC1090
source "${STACK_PATH}/loadLSST.bash"
eups distrib install "${ARGS[@]}"
