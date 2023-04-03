#!/bin/bash

# Script para fazer o Deploy da aplicação via Docker
set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
WORK_DIR=${SCRIPT_PATH}

. "$SCRIPT_PATH/00-setenv.sh"

myecho "Creating/initializing Oracle REST Data Services (ORDS) container - Container name: \"$ORDS_CONTAINER_NAME\"..."
#ORDS_CONTAINER_START_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

ORDS_WAIT_FOR_CONTAINER_TO_FULLY_INITIALIZE=false

if [[ $(check_container_status $ORDS_CONTAINER_NAME) == "$CONTAINER_RUNNING" ]]; then
    myecho "ORDS container \"$ORDS_CONTAINER_NAME\" is already running."
#    ORDS_CONTAINER_START_TIME=$(sudo docker inspect --format='{{.Created}}' $ORDS_CONTAINER_NAME)
elif [[ $(check_container_status $ORDS_CONTAINER_NAME) == "$CONTAINER_NOT_RUNNING" ]]; then
    myecho "ORDS container \"$ORDS_CONTAINER_NAME\" is stopped. Initializing..."
    sudo docker start $ORDS_CONTAINER_NAME
    ORDS_WAIT_FOR_CONTAINER_TO_FULLY_INITIALIZE=true
else
    myecho "ORDS container \"$ORDS_CONTAINER_NAME\" is not found. Creating and running the container..."
    sudo chown -Rf $ORDS_CONTAINER_USER_UID:$ORDS_CONTAINER_USER_UID $APEX_IMAGES_DIR
    sudo chown -Rf $ORDS_CONTAINER_USER_UID:$ORDS_CONTAINER_USER_UID $ORDS_CONFIG
    sudo chown -Rf $ORDS_CONTAINER_USER_UID:$ORDS_CONTAINER_USER_UID $ORDS_INSTALL_DIR

    sudo docker build --build-arg ARG_ORDS_CONTAINER_USER_UID=$ORDS_CONTAINER_USER_UID \
                      --build-arg ARG_ORDS_CONTAINER_CONFIG_DIR=$ORDS_CONTAINER_CONFIG_DIR \
                      --build-arg ARG_ORDS_FOLDER_NAME=$ORDS_FOLDER_NAME \
                      --build-arg ARG_DEFAULT_TIMEZONE=$DEFAULT_TIMEZONE \
                      -t $ORDS_CONTAINER_NAME .

    sudo docker run --name $ORDS_CONTAINER_NAME -h $ORDS_CONTAINER_NAME -d     \
                    -v $ORDS_CONFIG:$ORDS_CONTAINER_CONFIG_DIR \
                    -v $APEX_IMAGES_DIR:$ORDS_CONTAINER_APEX_IMAGES_DIR \
                    -p $ORDS_CONTAINER_HTTP_PORT:8080 \
                    -p $ORDS_CONTAINER_HTTPS_PORT:8443 \
                    -u $ORDS_CONTAINER_USER_UID:$ORDS_CONTAINER_USER_UID \
                    -e TZ=$DEFAULT_TIMEZONE  \
                    $ORDS_CONTAINER_NAME

    ORDS_WAIT_FOR_CONTAINER_TO_FULLY_INITIALIZE=true
fi

if [ "$ORDS_WAIT_FOR_CONTAINER_TO_FULLY_INITIALIZE" = true ] ; then
    myecho "Waiting for ORDS container \"$ORDS_CONTAINER_NAME\" to fully initialize. Please, be patient..."
    sleep 15
fi

myecho "Go to http://$(hostname -I | awk '{print $1}'):$ORDS_CONTAINER_HTTP_PORT/ords in your web browser to access Oracle Apex development environment."
myecho "To monitor Oracle database logs, enter the command \"sudo docker logs -n 100 -f $DB_CONTAINER_NAME\" in the terminal."
myecho "To monitor ORDS logs, enter the command \"sudo docker logs -n 100 -f $ORDS_CONTAINER_NAME\" in the terminal."

