#!/bin/bash
set -e

source $(dirname $0)/../../common.sh

read_cron_input(){

    CRON_FILE='./crontab'

    while test $# -gt 0; do
        case "$1" in
            --cron-file) full_path $2 && CRON_FILE=$2 ;;
        esac
        shift
    done

}

deploy_cron(){

    read_cron_input "$@"

    cat $CRON_FILE | crontab -

}

if [ "$0" = "$BASH_SOURCE" ]; then
    deploy_cron "$@"
fi
