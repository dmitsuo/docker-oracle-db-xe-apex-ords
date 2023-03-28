#!/bin/bash

#set -eux
set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

cd "$SCRIPT_PATH"/scripts

{
bash 10-start-db-container.sh
bash 30-start-ords-container.sh
} 2>&1 | tee -a "$SCRIPT_PATH/$(basename "$0").log"