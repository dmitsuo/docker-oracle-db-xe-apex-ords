#!/bin/bash

# Script para fazer o Deploy da aplicação via Docker
set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
WORK_DIR=${SCRIPT_PATH}

. "$SCRIPT_PATH/00-setenv.sh"

myecho "Creating/initializing Oracle REST Data Services (ORDS) container - Container name: \"$ORDS_CONTAINER_NAME\"..."

sudo chown -Rf $ORDS_CONTAINER_USER_UID:$ORDS_CONTAINER_USER_UID $APEX_IMAGES_DIR  || true \
&& sudo chown -Rf $ORDS_CONTAINER_USER_UID:$ORDS_CONTAINER_USER_UID $ORDS_CONFIG  || true \
&& sudo chown -Rf $ORDS_CONTAINER_USER_UID:$ORDS_CONTAINER_USER_UID $ORDS_INSTALL_DIR  || true \
&& sudo docker rm -f $ORDS_CONTAINER_NAME || true \
&& sudo docker rmi -f $ORDS_CONTAINER_NAME || true \
&& sudo docker build --build-arg ARG_ORDS_CONTAINER_USER_UID=$ORDS_CONTAINER_USER_UID \
                     --build-arg ARG_ORDS_CONTAINER_CONFIG_DIR=$ORDS_CONTAINER_CONFIG_DIR \
                     --build-arg ARG_ORDS_FOLDER_NAME=$ORDS_FOLDER_NAME \
                     --build-arg ARG_DEFAULT_TIMEZONE=$DEFAULT_TIMEZONE \
                      -t $ORDS_CONTAINER_NAME . \
&& sudo docker run --name $ORDS_CONTAINER_NAME -h $ORDS_CONTAINER_NAME -d     \
                   -v $ORDS_CONFIG:$ORDS_CONTAINER_CONFIG_DIR \
                   -v $APEX_IMAGES_DIR:$ORDS_CONTAINER_APEX_IMAGES_DIR \
                   -p $ORDS_CONTAINER_HTTP_PORT:8080 \
                   -p $ORDS_CONTAINER_HTTPS_PORT:8443 \
                   -u $ORDS_CONTAINER_USER_UID:$ORDS_CONTAINER_USER_UID \
                   -e TZ=$DEFAULT_TIMEZONE  \
                   $ORDS_CONTAINER_NAME                                \
&& echo -e "\n\n\n\n\n\n\n\n\n\n\n\n                                   Pressionar Ctrl+C para sair da exibicao dos logs...\n\n\n" \
&& sudo docker logs -f $ORDS_CONTAINER_NAME


