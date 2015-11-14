#!/bin/bash

set -o errexit

ARGS=()

if [ ! -z "$TAG" ]; then
  ARGS+=('-t')
  ARGS+=("$TAG")
fi
ARGS+=("$PRODUCTS")

export ARGS
#read -r -d '' CMD <<END
CMD=$(cat <<END
set -o errexit;
set -o verbose;
if grep -q -i "CentOS release 6" /etc/redhat-release; then
  . /opt/rh/devtoolset-3/enable;
fi;
set +o verbose;

source ${STACK_PATH}/loadLSST.bash;
eups distrib install ${ARGS[@]};
END
)

echo "$CMD"
echo "$CMD" | su - vagrant
