#!/bin/bash

set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

cd "$SCRIPT_PATH"/scripts

{
START_TIME=$(date +%s)

bash 05-pre-install.sh
bash 10-start-db-container.sh
bash 15-install-apex.sh
bash 20-install-ords.sh

END_TIME=$(date +%s)

. ./00-setenv.sh

myecho "$(elapsed_time $START_TIME $END_TIME)"

} 2>&1 | tee -a "$SCRIPT_PATH/$(basename "$0").log"
