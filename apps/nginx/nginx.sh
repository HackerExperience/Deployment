#!/bin/bash
set -e

source $(dirname $0)/../../common.sh

read_nginx_input(){

    NGINX_SRC_DIR='.'
    NGINX_CONTAINER_NAME='nginx'
    NGINX_CONTAINER_IMAGE='he_nginx_extras'
    NGINX_PORT='80'
    NGINX_CONF_DIR='/nginx-conf'
    NGINX_DATA_DIR='/nginx-data'

    while test $# -gt 0; do
        case "$1" in
            --nginx-src) full_path $2 && NGINX_SRC_DIR=$2 ;;
            --nginx-name) NGINX_CONTAINER_NAME=$2 ;;
            --nginx-image) NGINX_CONTAINER_IMAGE=$2 ;;
            --nginx-port) NGINX_PORT=$2 ;;
            --nginx-conf) full_path $2 && NGINX_CONF_DIR=$2 ;;
            --nginx-data) full_path $2 && NGINX_DATA_DIR=$2 ;;
            --skip-nginx) SKIP_NGINX=1 ;;
        esac
        shift
    done
}

deploy_nginx(){

    read_common_input "$@"
    read_nginx_input "$@"

    if [ $SKIP_NGINX ]; then
        echo 'Skipping Nginx...'
        return
    fi

    verify_conflict $NGINX_CONTAINER_NAME
    verify_conflict ${NGINX_CONTAINER_NAME}_data

    mkdir -p $NGINX_CONF_DIR
    mkdir -p $NGINX_DATA_DIR

    install_config nginx.conf $NGINX_SRC_DIR $NGINX_CONF_DIR
    install_config sites-enabled $NGINX_SRC_DIR $NGINX_CONF_DIR

    docker run -d \
        --name ${NGINX_CONTAINER_NAME}_data \
        -v ${NGINX_CONF_DIR}/nginx.conf:/etc/nginx/nginx.conf:ro \
        -v ${NGINX_CONF_DIR}/sites-enabled:/etc/nginx/sites-enabled:ro \
        -v ${NGINX_DATA_DIR}:/var/www:rw \
        busybox /bin/true

    docker run -d \
        --name $NGINX_CONTAINER_NAME \
        --volumes-from ${NGINX_CONTAINER_NAME}_data \
        -p ${NGINX_PORT}:80 \
        $NGINX_CONTAINER_IMAGE

    sleep 2

    verify_running NGINX_CONTAINER_NAME

}

if [ "$0" = "$BASH_SOURCE" ]; then
    deploy_nginx "$@"
fi
