#!/bin/bash
set -e

source $(dirname $0)/../../common.sh

read_mariadb_input(){

    MYSQL_SRC_DIR='.'
    MYSQL_ENV='MYSQL_RANDOM_ROOT_PASSWORD=1'
    MYSQL_CONTAINER_NAME='mysql'
    MYSQL_DATA_DIR='/mysql-data'
    MYSQL_CONF_DIR='/mysql-conf'
    MYSQL_PORT='3306'
    MYSQL_CONTAINER_IMAGE='he_mariadb'

    while test $# -gt 0; do
        case "$1" in
            # MySQL
            --mysql-src) full_path $2 && MYSQL_SRC_DIR=$2 ;;
            --mysql-env) MYSQL_ENV=$2 ;;
            --mysql-name) MYSQL_CONTAINER_NAME=$2 ;;
            --mysql-image) MYSQL_CONTAINER_IMAGE=$2 ;;
            --mysql-data) full_path $2 && MYSQL_DATA_DIR=$2 ;;
            --mysql-conf) full_path $2 && MYSQL_CONF_DIR=$2;;
            --mysql-port) MYSQL_PORT=$2 ;;
            --skip-mysql) SKIP_MYSQL=1 ;;
        esac
        shift
    done

}

deploy_mariadb(){

    read_common_input "$@"
    read_mariadb_input "$@"

    if [ $SKIP_MYSQL ]; then
        echo 'Skipping MySQL...'
        return
    fi

    verify_conflict $MYSQL_CONTAINER_NAME
    verify_conflict ${MYSQL_CONTAINER_NAME}_data

    mkdir -p ${LOGS_DIR}/${MYSQL_CONTAINER_NAME}
    mkdir -p $MYSQL_DATA_DIR
    mkdir -p $MYSQL_CONF_DIR

    install_config my.cnf $MYSQL_SRC_DIR $MYSQL_CONF_DIR

    docker run -d \
        --name ${MYSQL_CONTAINER_NAME}_data \
        -v ${MYSQL_DATA_DIR}:/var/lib/mysql:rw \
        -v /${MYSQL_CONF_DIR}/my.cnf:/etc/mysql/my.cnf:ro \
        -v ${LOGS_DIR}/${MYSQL_CONTAINER_NAME}:/var/log/mysql/:rw \
        busybox /bin/true

    sleep 0.5 

    docker run -d \
        --name $MYSQL_CONTAINER_NAME \
        --volumes-from ${MYSQL_CONTAINER_NAME}_data \
        -e ${MYSQL_ENV} \
        -p ${MYSQL_PORT}:3306 \
        $MYSQL_CONTAINER_IMAGE

    echo 'Sleeping for a while so MySQL can start.'
    sleep 15

    verify_running $MYSQL_CONTAINER_NAME

}

if [ "$0" = "$BASH_SOURCE" ]; then
    deploy_mariadb "$@"
fi
