#!/bin/bash

set -e

source $(dirname $0)/../../common.sh
source $(dirname $0)/../mariadb/mariadb.sh

read_phabricator_input(){
    
    PHABRICATOR_CONTAINER_NAME='phabricator'
    PHABRICATOR_CONFIG_DIR='/phabricator-config'
    PHABRICATOR_DATA_DIR='/phabricator-data'
    PHABRICATOR_SSH_PORT='22'
    APHLICT_SERVER_PORT='22280'
    APHLICT_CLIENT_PORT='22281'

    while test $# -gt 0; do
        case "$1" in
            --phab-name) PHABRICATOR_CONTAINER_NAME=$2 ;;
            --phab-conf) full_path $2 && PHABRICATOR_CONFIG_DIR=$2 ;;
            --phab-data) full_path $2 && PHABRICATOR_DATA_DIR=$2 ;;
            --phab-ssh-port) PHABRICATOR_SSH_PORT=$2 ;;
            --aphlict-server-port) APHLICT_SERVER_PORT=$2 ;;
            --aphlict-client-port) APHLICT_CLIENT_PORT=$2 ;;
        esac
        shift
    done

}

deploy_phabricator(){

    read_common_input "$@"
    read_phabricator_input "$@"

    verify_conflict ${PHABRICATOR_CONTAINER_NAME}_data
    
    mkdir -p $PHABRICATOR_CONFIG_DIR
    mkdir -p $PHABRICATOR_DATA_DIR

    docker run -d \
        --name ${PHABRICATOR_CONTAINER_NAME}_data \
        -v ${PHABRICATOR_CONFIG_DIR}:/config:ro \
        -v ${PHABRICATOR_DATA_DIR}/repositories:/var/repo:rw \
        -v ${PHABRICATOR_DATA_DIR}/backup:/tmp/backup:rw \
        busybox /bin/true

    docker run -d \
        --name=${PHABRICATOR_CONTAINER_NAME} \
        --volumes-from ${PHABRICATOR_CONTAINER_NAME}_data \
        -p ${PHABRICATOR_SSH_PORT}:22 \
        -p ${APHLICT_CLIENT_PORT}:22280 \
        -p ${APHLICT_SERVER_PORT}:22281 \
        phabricator

}

if [ "$0" = "$BASH_SOURCE" ]; then
    
    deploy_mariadb "$@"
    deploy_phabricator "$@"

fi
