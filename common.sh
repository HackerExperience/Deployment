#!/bin/bash
set -e

exit_msg(){
    echo "$1 \n Stopping."
    exit 1
}

container_exists(){
    docker ps -a | grep -iq $1
}

container_running(){
    docker ps | grep -iq $1
}

verify_conflict(){
    if container_exists $1; then
        exit_msg "Conflicting container with name $1." 
    fi
}

verify_running(){
    if ! container_running $1; then
        exit_msg "$1 failed to start. Use docker logs $1."
    else
        echo "$1 seems to be running."
    fi
}

full_path(){
    # /absolute/path/without/trailing/slash/is/ok
    # /this/will/fail/
    # relative/path/fails/too
    [[ $1 == /* && ! $1 == */ ]] || exit_msg "Invalid path $1. Must be absolute and *not* end with a slash."
}

install_config(){
    if [ ! -e ${CONFIG_DIR}/$1 ]; then
        exit_msg "Config file/folder $1 not found at ${CONFIG_DIR}."
    fi

    # Avoid dev mistakes by ensuring full path
    full_path $2 

    if [ ! -d $2 ]; then
        exit_msg "Destination dir $2 not found."
    fi

    cp -r ${CONFIG_DIR}/$1 ${2}/$1 || exit_msg "Failed to execute command: cp -r ${CONFIG_DIR}/$1 ${2}/$1"
}

read_common_input(){

    # General
    LOGS_DIR='/logs'
    CONFIG_DIR='.'

    while test $# -gt 0
    do
        case "$1" in
            # general
            --logs-dir) full_path $2 && LOGS_DIR=$2 ;;
            --config-dir) full_path $2 && CONFIG_DIR=$2 ;;
        esac
        shift
    done

}

