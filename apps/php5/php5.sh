#!/bin/bash
set -e

source $(dirname $0)/../../common.sh

read_php5_input(){

    PHP_SRC_DIR='.'
    PHP_CONTAINER_NAME='php5'
    PHP_CONTAINER_IMAGE='he_php5'
    PHP_CONF_DIR='/php5-conf'
    PHP_SOCKET_DIR='/php5-socket'

    while test $# -gt 0; do
        case "$1" in
            --php-src) full_path $2 && PHP_SRC_DIR=$2 ;;
            --php-name) PHP_CONTAINER_NAME=$2 ;;
            --php-image) PHP_CONTAINER_IMAGE=$2 ;;
            --php-conf) full_path $2 && PHP_CONF_DIR=$2 ;;
            --php-data) full_path $2 && PHP_DATA_DIR=$2 ;;
            --php-port) PHP_PORT=$2 ;;
            --php-with-socket) PHP_WITH_SOCKET=1 ;;
            --php-socket-dir) full_path $2 && PHP_SOCKET_DIR=$2 ;;
            --mysql-socket) PHP_USE_MYSQL=1 && MYSQL_SOCKET_NAME=$2 ;;
            --skip-php) SKIP_PHP=1 ;;
        esac
        shift
    done

}

deploy_php5(){

    ############################################################################
    # READ INPUT
    ############################################################################

    read_common_input "$@"
    read_php5_input "$@"

    if [ $SKIP_PHP ]; then
        echo 'Skipping PHP...' && return
    fi

    ############################################################################
    # CHECK REQUIREMENTS
    ############################################################################

    verify_conflict $PHP_CONTAINER_NAME
    verify_conflict ${PHP_CONTAINER_NAME}_data
    verify_conflict ${PHP_CONTAINER_NAME}_socket
    verify_conflict ${PHP_CONTAINER_NAME}_socket_data

    if [ $PHP_USE_MYSQL ]; then
        verify_exists $MYSQL_SOCKET_NAME
    fi

    ############################################################################
    # SETUP HOST ENVIRONMENT
    ############################################################################

    mkdir -p $PHP_CONF_DIR
    if [ $PHP_WITH_SOCKET ]; then
        mkdir -p $PHP_SOCKET_DIR

        # This is required because github.com/docker/docker/issues/2259
        chown -R 1000:101 $PHP_SOCKET_DIR
    fi

    install_config php.ini $PHP_SRC_DIR $PHP_CONF_DIR
    install_config php-fpm.conf $PHP_SRC_DIR $PHP_CONF_DIR

    ############################################################################
    # LAUNCH CONTAINERS
    ############################################################################

    extra_volumes=''
    if [ $PHP_DATA_DIR ]; then
        extra_volumes+="-v ${PHP_DATA_DIR}:/var/www:rw "
    fi

    # Main data container
    docker run -d \
        --name ${PHP_CONTAINER_NAME}_data \
        -v ${PHP_CONF_DIR}:/etc/php:rw \
        -v ${LOGS_DIR}/${PHP_CONTAINER_NAME}:/var/log/php:rw \
        $extra_volumes \
        busybox /bin/true

    extra_volumes=""

    # Socket data container
    if [ $PHP_WITH_SOCKET ]; then
        docker run -d \
            --name ${PHP_CONTAINER_NAME}_socket_data \
            -v ${PHP_SOCKET_DIR}:/var/run/php:rw \
            busybox /bin/true
        extra_volumes+=" --volumes-from ${PHP_CONTAINER_NAME}_socket_data "
    fi
    
    if [ $PHP_USE_MYSQL ]; then        
        extra_volumes+=" --volumes-from ${MYSQL_SOCKET_NAME} "
    fi

    container_ports=""
    if [ $PHP_PORT ]; then
        container_ports+=" -p ${PHP_PORT}:9000 "
    fi

    # Application container
    docker run -d \
        --name $PHP_CONTAINER_NAME \
        --volumes-from ${PHP_CONTAINER_NAME}_data \
        $extra_volumes \
        $container_ports \
        $PHP_CONTAINER_IMAGE

    sleep 2

    # Socket-interfacing container
    if [ $PHP_WITH_SOCKET ]; then
        docker run -d \
            --name ${PHP_CONTAINER_NAME}_socket \
            --volumes-from ${PHP_CONTAINER_NAME}_socket_data \
            busybox /bin/true
    fi

    verify_running $PHP_CONTAINER_NAME

}

if [ "$0" = "$BASH_SOURCE" ]; then
    deploy_php5 "$@"
fi
