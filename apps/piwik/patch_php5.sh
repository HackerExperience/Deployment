#!/bin/bash
set -e

source $(dirname $0)/../../common.sh

read_php5_input(){

    PHP_CONTAINER_NAME='php5'
    PIWIK_DATA_DIR='/piwik-data'

    while test $# -gt 0; do
        case "$1" in
            --php-name) PHP_CONTAINER_NAME=$2 ;;
        esac
        shift
    done
}

patch_php5(){

    verify_running $PHP_CONTAINER_NAME

    docker exec -d $PHP_CONTAINER_NAME /sbin/apk --refresh add --no-cache php-zlib php-dom

    sleep 3

    docker exec -d 

}

if [ "$0" = "$BASH_SOURCE" ]; then
    patch_php5 "$@"
fi
