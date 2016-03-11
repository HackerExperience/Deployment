#!/bin/bash
set -e

source $(dirname $0)/../../common.sh

read_mariadb_input(){

    MYSQL_SRC_DIR='.'
    MYSQL_ENV='MYSQL_RANDOM_ROOT_PASSWORD=1'
    MYSQL_CONTAINER_NAME='mysql'
    MYSQL_DATA_DIR='/mysql-data'
    MYSQL_CONF_DIR='/mysql-conf'
    MYSQL_CONTAINER_IMAGE='he_mariadb'
    MYSQL_SOCKET_DIR='/mysql-socket'

    while test $# -gt 0; do
        case "$1" in
            # MySQL
            --mysql-src) full_path $2 && MYSQL_SRC_DIR=$2 ;;
            --mysql-env) MYSQL_ENV=$2 ;;
            --mysql-name) MYSQL_CONTAINER_NAME=$2 ;;
            --mysql-image) MYSQL_CONTAINER_IMAGE=$2 ;;
            --mysql-data) full_path $2 && MYSQL_DATA_DIR=$2 ;;
            --mysql-conf) full_path $2 && MYSQL_CONF_DIR=$2 ;;
            --mysql-port) MYSQL_PORT=$2 ;;
            --mysql-with-socket) MYSQL_WITH_SOCKET=1 ;;
            --mysql-socket-dir) full_path $2 && MYSQL_SOCKET_DIR=$2 ;;
            --skip-mysql) SKIP_MYSQL=1 ;;
        esac
        shift
    done

}

deploy_mariadb(){

    ############################################################################
    # READ INPUT
    ############################################################################

    read_common_input "$@"
    read_mariadb_input "$@"

    if [ $SKIP_MYSQL ]; then
        echo 'Skipping MySQL...'
        return
    fi

    ############################################################################
    # CHECK REQUIREMENTS
    ############################################################################

    verify_conflict $MYSQL_CONTAINER_NAME
    verify_conflict ${MYSQL_CONTAINER_NAME}_data
    verify_conflict ${MYSQL_CONTAINER_NAME}_socket
    verify_conflict ${MYSQL_CONTAINER_NAME}_socket_data

    ############################################################################
    # SETUP HOST ENVIRONMENT
    ############################################################################

    mkdir -p ${LOGS_DIR}/${MYSQL_CONTAINER_NAME}
    mkdir -p $MYSQL_DATA_DIR
    mkdir -p $MYSQL_CONF_DIR
    if [ $MYSQL_WITH_SOCKET ]; then
        mkdir -p $MYSQL_SOCKET_DIR

        # This is required because github.com/docker/docker/issues/2259
        chown -R 1000:101 $MYSQL_SOCKET_DIR
    fi

    install_config my.cnf $MYSQL_SRC_DIR $MYSQL_CONF_DIR

    ############################################################################
    # LAUNCH CONTAINERS
    ############################################################################

    docker run -d \
        --name ${MYSQL_CONTAINER_NAME}_data \
        -v ${MYSQL_DATA_DIR}:/var/lib/mysql:rw \
        -v /${MYSQL_CONF_DIR}/my.cnf:/etc/mysql/my.cnf:ro \
        -v ${LOGS_DIR}/${MYSQL_CONTAINER_NAME}:/var/log/mysql/:rw \
        busybox /bin/true

    sleep 0.2

    container_ports=""
    if [ $MYSQL_PORT ]; then
        container_ports+=" -p ${MYSQL_PORT}:3306 " 
    fi

    extra_volumes=""
    if [ $MYSQL_WITH_SOCKET ]; then
        docker run -d \
            --name ${MYSQL_CONTAINER_NAME}_socket_data \
            -v ${MYSQL_SOCKET_DIR}:/run/mysqld/:rw \
            busybox /bin/true
        extra_volumes+=" --volumes-from ${MYSQL_CONTAINER_NAME}_socket_data:rw "
    fi

    docker run -d \
        --name $MYSQL_CONTAINER_NAME \
        --volumes-from ${MYSQL_CONTAINER_NAME}_data \
        ${extra_volumes} \
        -e ${MYSQL_ENV} \
        ${container_ports} \
        $MYSQL_CONTAINER_IMAGE

    if [ $MYSQL_WITH_SOCKET ]; then
        docker run -d \
            --name ${MYSQL_CONTAINER_NAME} \
            --volumes-from $MYSQL_CONTAINER_NAME \
            busybox /bin/true
    fi

    echo 'Sleeping for a while so MySQL can start.'
    sleep 20

    verify_running $MYSQL_CONTAINER_NAME

}

if [ "$0" = "$BASH_SOURCE" ]; then
    deploy_mariadb "$@"
fi
