#!/bin/bash
set -e

source $(dirname $0)/../../common.sh

read_piwik_input(){

    PIWIK_CONTAINER_NAME='piwik'
    PIWIK_DATA_DIR='/piwik-data'

    while test $# -gt 0; do
        case "$1" in
            --piwik-name) PIWIK_CONTAINER_NAME=$2 ;;
            --piwik-data) full_path $2 && PIWIK_DATA_DIR=$2 ;;
        esac
        shift
    done
}

deploy_piwik(){

    docker run -d \
        --name ${PIWIK_CONTAINER_NAME}_data \
        -v ${PIWIK_DATA_DIR}:/var/www:rw \
        piwik /bin/true

    sleep 3

}

if [ "$0" = "$BASH_SOURCE" ]; then
    deploy_piwik "$@"
fi
