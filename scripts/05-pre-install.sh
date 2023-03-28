#!/bin/bash

#set -eux
set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

. "$SCRIPT_PATH/00-setenv.sh"

TXT_NOT_FOUND="not found"
TXT_TRY_DOWNLOAD="Installation package $TXT_NOT_FOUND. Trying to download..."
TXT_DOWNLOAD_COMPLETE="Installation package download completed!"
TXT_DECOMPRESSING="Decompressing installation package..."
TXT_SUCCESS_DECOMP="Installation package successfully decompressed!"
TXT_FOUND_NOTHING_TODO="found, nothing to do..."

myecho "Starting APEX 22.2 and ORDS 22.4 pre-installation..."

if [ ! -f $JAVA_EXE ]; then
    myecho "JAVA: Executable $TXT_NOT_FOUND"
    if [ ! -f $JAVA_INSTALL_PACKAGE ]; then
        myecho "JAVA: $TXT_TRY_DOWNLOAD"
        curl -L -k -o $JAVA_INSTALL_PACKAGE $JAVA_JRE_DOWNLOAD_URL
        myecho "JAVA: $TXT_DOWNLOAD_COMPLETE"
    fi
    myecho "JAVA: $TXT_DECOMPRESSING"
    tar -xzf "$JAVA_INSTALL_PACKAGE"
    myecho "JAVA: $TXT_SUCCESS_DECOMP"
else 
    myecho "JAVA: Executable $TXT_FOUND_NOTHING_TODO"
fi

if [ ! -f $APEX_INSTALL_SCRIPT ]; then
    myecho "APEX: Installation script $TXT_NOT_FOUND"
    if [ ! -f $APEX_INSTALL_PACKAGE ]; then
        myecho "APEX: $TXT_TRY_DOWNLOAD"
        curl -L -k -o $APEX_INSTALL_PACKAGE $APEX_DOWNLOAD_URL
        myecho "APEX: $TXT_DOWNLOAD_COMPLETE"
    fi
    myecho "APEX: $TXT_DECOMPRESSING"
    unzip -q "$APEX_INSTALL_PACKAGE" -d "$APEX_INSTALL_DIR"
    myecho "APEX: $TXT_SUCCESS_DECOMP"
else 
    myecho "APEX: Installation script $TXT_FOUND_NOTHING_TODO"
fi

if [ ! -f $ORDS_EXE ]; then
    myecho "ORDS: Executable $TXT_NOT_FOUND"
    if [ ! -f $ORDS_INSTALL_PACKAGE ]; then
        myecho "ORDS: $TXT_TRY_DOWNLOAD"
        curl -L -k -o $ORDS_INSTALL_PACKAGE $ORDS_DOWNLOAD_URL
        myecho "ORDS: $TXT_DOWNLOAD_COMPLETE"
    fi
    myecho "ORDS: $TXT_DECOMPRESSING"
    unzip -q "$ORDS_INSTALL_PACKAGE" -d "$ORDS_INSTALL_DIR"
    myecho "ORDS: $TXT_SUCCESS_DECOMP"
else 
    myecho "ORDS: Executable $TXT_FOUND_NOTHING_TODO"    
fi

myecho "APEX 22.2 and ORDS 22.4 pre-installation completed!"