#!/bin/bash

set -e

source $(dirname $0)/../../common.sh

read_jenkins_input(){
    
    JENKINS_CONTAINER_NAME='jenkins'
    JENKINS_DATA_DIR='/jenkins-data'
    JENKINS_WEB_PORT='8080'

    while test $# -gt 0; do
        case "$1" in
            --jenkins-src) full_path $2 && JENKINS_SRC_DIR=$2 ;;
            --jenkins-name) JENKINS_CONTAINER_NAME=$2 ;;
            --jenkins-data) full_path $2 && JENKINS_DATA_DIR=$2 ;;
            --jenkins-web-port) JENKINS_WEB_PORT=$2 ;;
        esac
        shift
    done

}

deploy_jenkins(){

    read_common_input "$@"
    read_jenkins_input "$@"

    verify_conflict ${JENKINS_CONTAINER_NAME}_data

    mkdir -p $JENKINS_DATA_DIR

    docker run -d \
        --name ${JENKINS_CONTAINER_NAME}_data \
        -v ${JENKINS_DATA_DIR}:/var/jenkins_home:rw \
        ${extra_volumes}
        busybox /bin/true

    # We need to have a `jenkins` user on the host due to volume permissions.
    id -u jenkins &>/dev/null || useradd -MNs /dev/null jenkins

    jenkins_uid=$(id -u jenkins)
    chown -R jenkins_uid $JENKINS_DATA_DIR

    container_ports=""
    if [ -n "${JENKINS_WEB_PORT}" ]; then
        container_ports+="-p ${JENKINS_WEB_PORT}:8080 " 
    fi

    docker run -d \
        --name ${JENKINS_CONTAINER_NAME} \
        --volumes-from ${JENKINS_CONTAINER_NAME}_data \
        ${ports}
        -u $(id -u jenkins)
        jenkins

}

if [ "$0" = "$BASH_SOURCE" ]; then

    deploy_jenkins "$@"

fi
