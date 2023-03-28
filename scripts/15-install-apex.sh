#!/bin/bash

#set -eux
set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

. "$SCRIPT_PATH/00-setenv.sh"

sudo chmod 755 "$SCRIPT_PATH/16-install-apex-internal.sh"

myecho "Installing Oracle Application Express (APEX)..."

sudo docker exec $DB_CONTAINER_NAME /bin/bash /opt/temp/16-install-apex-internal.sh

myecho "APEX installation completed!"
