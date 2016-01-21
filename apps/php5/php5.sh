#!/bin/bash
set -e

source $(dirname $0)/../../common.sh

read_php5_input(){

    PHP_CONTAINER_NAME='php5'
    PHP_CONTAINER_IMAGE='he_php5'
    PHP_PORT='9000'
    PHP_CONF_DIR='/php-conf'

    while test $# -gt 0; do
        case "$1" in
            --php-name) PHP_CONTAINER_NAME=$2 ;;
            --php-image) PHP_CONTAINER_IMAGE=$2 ;;
            --php-conf) full_path $2 && PHP_CONF_DIR=$2 ;;
            --php-port) PHP_PORT=$2 ;;
            --skip-php) SKIP_PHP=1 ;;
        esac
        shift
    done

}

deploy_php5(){

    read_common_input "$@"
    read_php5_input "$@"

    if [ $SKIP_PHP ]; then
        echo 'Skipping PHP...' && return
    fi

    verify_conflict $PHP_CONTAINER_NAME
    verify_conflict ${PHP_CONTAINER_NAME}_data

    mkdir -p $PHP_CONF_DIR

    install_config php.ini $PHP_CONF_DIR
    install_config php-fpm.ini $PHP_CONF_DIR
    install_config conf.d $PHP_CONF_DIR

    docker run -d \
        --name $PHP_CONTAINER_NAME \
        -v ${PHP_CONF_DIR}/php.ini:/etc/php.ini:ro \
        -v ${PHP_CONF_DIR}/php-fpm.ini:/etc/php-fpm.ini:ro \
        -v ${PHP_CONF_DIR}/conf.d:/etc/php/conf.d:rw \
        busybox /bin/true

    docker run -d \
        --name $PHP_CONTAINER_NAME \
        --volumes-from ${PHP_CONTAINER_NAME}_data \
        -p $PHP_PORT:9000 \
        $PHP_CONTAINER_IMAGE

    sleep 2

    verify_running NGINX_CONTAINER_NAME

}

if [ "$0" = "$BASH_SOURCE" ]; then
    deploy_php5 "$@"
fi
