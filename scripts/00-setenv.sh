#!/bin/bash

set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

DEFAULT_TIMEZONE="America/Fortaleza"

# Oracle Database XE 18c
DB_LISTENER_TCP_PORT=1551
DB_ADMIN_USER="SYS AS SYSDBA"
DB_ADMIN_PWD="123"
DB_CONTAINER_NAME=oracle-xe-18-mcp-ap
DB_CONTAINER_VOLUME=${DB_CONTAINER_NAME}
DB_SERVICENAME=XEPDB1

# Java JRE 11
JAVA_HOME="$SCRIPT_PATH/jdk-11.0.18+10-jre"
JAVA_EXE="$JAVA_HOME/bin/java"
JAVA_JRE_DOWNLOAD_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.18%2B10/OpenJDK11U-jre_x64_linux_hotspot_11.0.18_10.tar.gz"
JAVA_INSTALL_PACKAGE="$SCRIPT_PATH/OpenJDK11U-jre_x64_linux_hotspot_11.0.18_10.tar.gz"

# Oracle Application Express (APEX) 22.2
APEX_INSTALL_SCRIPT="$SCRIPT_PATH/apex_22.2/apex/apexins.sql"
APEX_DOWNLOAD_URL="https://download.oracle.com/otn_software/apex/apex_22.2.zip"
APEX_INSTALL_DIR="$SCRIPT_PATH/apex_22.2"
APEX_INSTALL_PACKAGE=${APEX_INSTALL_DIR}.zip
APEX_INTERNAL_CONTAINER_DIR=/opt/apex
APEX_ADMIN_EMAIL=myemail@domain.com
APEX_ADMIN_PWD="SET_APEX_ADM1N_PWD_HERe_!"
APEX_DB_USER="APEX_220200"
APEX_IMAGES_DIR="$APEX_INSTALL_DIR"/apex/images

# Oracle REST Data Services (ORDS) 22.4
ORDS_FOLDER_NAME="ords-22.4.4.041.1526"
ORDS_EXE="$SCRIPT_PATH/$ORDS_FOLDER_NAME/bin/ords"
ORDS_DOWNLOAD_URL="https://download.oracle.com/otn_software/java/ords/ords-22.4.4.041.1526.zip"
ORDS_INSTALL_DIR="$SCRIPT_PATH/$ORDS_FOLDER_NAME"
ORDS_INSTALL_PACKAGE=${ORDS_INSTALL_DIR}.zip
ORDS_PROXY_USER_TABLESPACE=SYSAUX
ORDS_PROXY_USER_TEMP_TABLESPACE=TEMP
ORDS_SCHEMA_TABLESPACE=SYSAUX
ORDS_SCHEMA_TEMP_TABLESPACE=TEMP
ORDS_FEATURE_SDW=true
ORDS_CONFIG="$SCRIPT_PATH/ords-config"
ORDS_LOGS="$SCRIPT_PATH/ords-logs"
ORDS_CONTAINER_NAME=ords-22-4-mcp-ap
ORDS_CONTAINER_HTTP_PORT=20231
ORDS_CONTAINER_HTTPS_PORT=20232
ORDS_CONTAINER_USER_UID=1000
ORDS_CONTAINER_TOMCAT_DIR=/usr/local/tomcat
ORDS_CONTAINER_CONFIG_DIR=/opt/ords-config
ORDS_CONTAINER_APEX_IMAGES_DIR=${ORDS_CONTAINER_TOMCAT_DIR}/webapps/i
ORDS_DB_CONTAINER_INTERNAL_IP=172.17.0.1

### FAVOR NAO ALTERAR NADA A PARTIR DESTE PONTO PARA BAIXO
### PLEASE DO NOT ALTER ANYTHING FROM THIS POINT DOWNWARDS

myecho() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

CONTAINER_RUNNING="RUNNING"
CONTAINER_NOT_RUNNING="NOT_RUNNING"
CONTAINER_NOT_FOUND="NOT_FOUND"

# Example usage:
#if [[ $(check_container_status my-container) == "$CONTAINER_RUNNING" ]]; then
#  echo "The container is running."
#  # Execute task for container is running
#elif [[ $(check_container_status my-container) == "$CONTAINER_NOT_RUNNING" ]]; then
#  echo "The container exists, but is not running."
#  # Execute task for container exists but is not running
#else
#  echo "The container doesn't exist."
#  # Execute task for container doesn't exist
#fi

check_container_status() {
  if [ "$(sudo docker inspect -f '{{.State.Running}}' $1 2>/dev/null)" = "true" ]; then
    echo "$CONTAINER_RUNNING"
  elif [ "$(sudo docker inspect -f '{{.State.Status}}' $1 2>/dev/null)" = "exited" ]; then
    echo "$CONTAINER_NOT_RUNNING"
    # Execute task for container exists but is not running
  else
    echo "$CONTAINER_NOT_FOUND"
    # Execute task for container doesn't exist
  fi
}

elapsed_time() {
    local start=$1
    local end=$2
    local elapsed=$((end - start))

    local hours=$((elapsed / 3600))
    local minutes=$(( (elapsed % 3600) / 60 ))
    local seconds=$((elapsed % 60))

    printf "Elapsed time: %02dh %02dm %02ds\n" $hours $minutes $seconds
}
