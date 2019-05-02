#!/bin/bash

set -o errexit

ARGS=()

if [ -n "$TAG" ]; then
  ARGS+=('-t')
  ARGS+=("$TAG")
fi
ARGS+=("$PRODUCTS")

export ARGS
#read -r -d '' CMD <<END
CMD=$(cat <<END
set -o errexit;

source ${STACK_PATH}/loadLSST.bash;
eups distrib install ${ARGS[@]};
END
)

echo "$CMD"
echo "$CMD" | su - vagrant
