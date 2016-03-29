#!/bin/bash

set -e

source $(dirname $0)/../../common.sh
source $(dirname $0)/../mariadb/mariadb.sh

read_phabricator_input(){
    
    PHABRICATOR_CONTAINER_NAME='phabricator'
    PHABRICATOR_SRC_DIR='.'
    PHABRICATOR_CONFIG_DIR='/phabricator-config'
    PHABRICATOR_DATA_DIR='/phabricator-data'
    PHABRICATOR_SSH_PORT='22'
    PHABRICATOR_CUSTOM_VOLUMES=""
    APHLICT_SERVER_PORT='22280'
    APHLICT_CLIENT_PORT='22281'

    while test $# -gt 0; do
        case "$1" in
            --phab-name) PHABRICATOR_CONTAINER_NAME=$2 ;;
            --phab-src) full_path $2 && PHABRICATOR_SRC_DIR=$2 ;;
            --phab-conf) full_path $2 && PHABRICATOR_CONFIG_DIR=$2 ;;
            --phab-data) full_path $2 && PHABRICATOR_DATA_DIR=$2 ;;
            --phab-ssh-port) PHABRICATOR_SSH_PORT=$2 ;;
            --phab-custom-volume) PHABRICATOR_CUSTOM_VOLUMES+="$2 " ;;
            --aphlict-server-port) APHLICT_SERVER_PORT=$2 ;;
            --aphlict-client-port) APHLICT_CLIENT_PORT=$2 ;;
            --skip-aphlict) SKIP_APHLICT=1 ;;
        esac
        shift
    done

}

deploy_phabricator(){

    ############################################################################
    # READ INPUT
    ############################################################################

    read_common_input "$@"
    read_phabricator_input "$@"

    ############################################################################
    # CHECK REQUIREMENTS
    ############################################################################

    verify_conflict ${PHABRICATOR_CONTAINER_NAME}_data

    ############################################################################
    # SETUP HOST ENVIRONMENT
    ############################################################################

    mkdir -p $PHABRICATOR_CONFIG_DIR
    mkdir -p $PHABRICATOR_DATA_DIR

    install_config nginx $PHABRICATOR_SRC_DIR $PHABRICATOR_CONFIG_DIR
    install_config php $PHABRICATOR_SRC_DIR $PHABRICATOR_CONFIG_DIR

    # This is required because github.com/docker/docker/issues/2259
    chown -R 497:495 $PHABRICATOR_CONFIG_DIR

    ############################################################################
    # LAUNCH CONTAINERS
    ############################################################################

    extra_volumes=""
    if [[ $PHABRICATOR_CUSTOM_VOLUMES  != "" ]]; then
        declare -a arr=($PHABRICATOR_CUSTOM_VOLUMES)
        for volume in "${arr[@]}"; do
           extra_volumes+=" -v $volume "
        done    
    fi

    docker run -d \
        --name ${PHABRICATOR_CONTAINER_NAME}_data \
        -v ${PHABRICATOR_CONFIG_DIR}:/config:ro \
        -v ${PHABRICATOR_CONFIG_DIR}/php/php-fpm.conf:/etc/php5/php-fpm.conf \
        -v ${PHABRICATOR_CONFIG_DIR}/php/php.ini:/etc/php5/fpm/php.ini \
        -v ${PHABRICATOR_CONFIG_DIR}/nginx/server.conf:/etc/nginx/servers/http.conf \
        -v ${PHABRICATOR_CONFIG_DIR}/nginx/nginx.conf:/etc/nginx/nginx.conf  \
        -v ${PHABRICATOR_CONFIG_DIR}/nginx/php.conf:/etc/nginx/php.conf \
        -v ${PHABRICATOR_DATA_DIR}/repositories:/var/repo:rw \
        -v ${PHABRICATOR_DATA_DIR}/backup:/tmp/backup:rw \
        busybox /bin/true

    aphlict_ports=""
    if [ -z $SKIP_APHLICT ]; then
        aphlict_ports+=" -p ${APHLICT_CLIENT_PORT}:22280 "
        aphlict_ports+=" -p ${APHLICT_SERVER_PORT}:22281 "
    fi

    docker run -d \
        --name=${PHABRICATOR_CONTAINER_NAME} \
        --volumes-from ${PHABRICATOR_CONTAINER_NAME}_data \
        ${extra_volumes} \
        ${aphlict_ports} \
        -p ${PHABRICATOR_SSH_PORT}:22 \
        phabricator

}

if [ "$0" = "$BASH_SOURCE" ]; then
    
    deploy_mariadb "$@"
    deploy_phabricator "$@"

fi
