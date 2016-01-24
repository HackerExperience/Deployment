#!/bin/bash

set -e

source $(dirname $0)/../../common.sh
source $(dirname $0)/../mariadb/mariadb.sh
source $(dirname $0)/../nginx/nginx.sh
source $(dirname $0)/../php5/php5.sh

read_phabricator_input(){
    
    PHABRICATOR_CONTAINER_NAME='phabricator'
    PHABRICATOR_ROOT='/phabricator'
    PHABRICATOR_DATA='/phabricator-data'

    while test $# -gt 0; do
        case "$1" in
            --phab-src) full_path $2 && PHP_SRC_DIR=$2 ;;
            --phab-name) PHABRICATOR_CONTAINER_NAME=$2 ;;
            --phab-root) full_path $2 && PHABRICATOR_ROOT=$2 ;;
            --phab-data) full_path $2 && PHABRICATOR_DATA=$2 ;;
        esac
        shift
    done

}

deploy_phabricator(){

    read_common_input "$@"
    read_phabricator_input "$@"

    verify_conflict ${PHABRICATOR_CONTAINER_NAME}_data

    mkdir -p $PHABRICATOR_ROOT
    mkdir -p $PHABRICATOR_DATA

    #install_config nginx.conf $NGINX_SRC_DIR $NGINX_CONF_DIR
    #install_config sites-enabled $NGINX_SRC_DIR $NGINX_CONF_DIR
    #install_config nginx.d $NGINX_SRC_DIR $NGINX_CONF_DIR

    docker run -d \
        --name ${PHABRICATOR_CONTAINER_NAME}_data \
        -v ${PHABRICATOR_DATA}:/phabricator-data:rw \
        -v ${PHABRICATOR_ROOT}:/var/www/phabricator:rw \
        busybox /bin/true
}

if [ "$0" = "$BASH_SOURCE" ]; then

    deploy_phabricator "$@"
    deploy_mariadb "$@"

    set -- "--php-data" "${PHABRICATOR_ROOT}" "--mysql-socket" "${MYSQL_SOCKET_NAME}" "$@"
    echo 321;
    echo "$@"


    deploy_php5 "$@"

    set -- "--nginx-data" "${PHABRICATOR_ROOT}" "--php-socket" "${PHP_CONTAINER_NAME}" "$@"
    echo 123;
    echo "$@"

    deploy_nginx "$@"

fi


./phabricator.sh --nginx-src /config/nginx --nginx-image he_nginx_extras --php-src /config/php5 --mysql-env MYSQL_RANDOM_ROOT_PASSWORD=1 \
        --mysql-src /config/mariadb
