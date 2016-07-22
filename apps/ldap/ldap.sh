#!/bin/bash

set -e

source $(dirname $0)/../../common.sh

read_ldap_input(){
    
    LDAP_CONTAINER_NAME='ldap'
    LDAP_SRC_DIR='.'
    LDAP_CONFIG_DIR='/ldap-config'
    LDAP_DATA_DIR='/ldap-data'
    LDAP_CUSTOM_VOLUME=""

    while test $# -gt 0; do
        case "$1" in
            --ldap-name) LDAP_CONTAINER_NAME=$2 ;;
            --ldap-src) full_path $2 && LDAP_SRC_DIR=$2 ;;
            --ldap-conf) full_path $2 && LDAP_CONFIG_DIR=$2 ;;
            --ldap-data) full_path $2 && LDAP_DATA_DIR=$2 ;;
            --ldap-custom-volume) LDAP_CUSTOM_VOLUME+="$2 " ;;
            --ldap-port) LDAP_PORT=$2 ;;
        esac
        shift
    done

}

deploy_ldap(){

    ############################################################################
    # READ INPUT
    ############################################################################

    read_common_input "$@"
    read_ldap_input "$@"

    ############################################################################
    # CHECK REQUIREMENTS
    ############################################################################

    verify_conflict $LDAP_CONTAINER_NAME
    verify_conflict ${LDAP_CONTAINER_NAME}_data

    ############################################################################
    # SETUP HOST ENVIRONMENT
    ############################################################################

    mkdir -p $LDAP_CONFIG_DIR
    mkdir -p $LDAP_DATA_DIR

    ############################################################################
    # LAUNCH CONTAINERS
    ############################################################################

    extra_volumes=""
    if [[ $LDAP_CUSTOM_VOLUME  != "" ]]; then
        declare -a arr=($LDAP_CUSTOM_VOLUME)
        for volume in "${arr[@]}"; do
           extra_volumes+=" -v $volume "
        done    
    fi

    container_ports=""
    if [ $LDAP_PORT ]; then
        container_ports+=" -p $LDAP_PORT:389 "
    fi

    docker run -d \
        --name ${LDAP_CONTAINER_NAME}_data \
        -v $LDAP_DATA_DIR:/var/lib/ldap \
        -v $LDAP_CONFIG_DIR:/etc/ldap/slapd.d \
        busybox /bin/true

    docker run -d \
        --name=${LDAP_CONTAINER_NAME} \
        --volumes-from ${LDAP_CONTAINER_NAME}_data \
        ${extra_volumes} \
        ${container_ports} \
        osixia/openldap:1.1.2

}

if [ "$0" = "$BASH_SOURCE" ]; then
    
    deploy_ldap "$@"

fi
