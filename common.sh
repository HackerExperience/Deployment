#!/bin/bash
set -e

exit_msg(){
    echo "$1 \n Stopping."
    exit 1
}

container_exists(){
    docker ps -a --format "{{.Names}}" | grep -iq $1
}

container_running(){
    docker ps --format "{{.Names}}" | grep -iq $1
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
    if [ ! -e ${2}/$1 ]; then
        exit_msg "Config file/folder $1 not found at ${2}."
    fi

    # Avoid dev mistakes by ensuring full path
    full_path $3 

    if [ ! -d $3 ]; then
        exit_msg "Destination dir $3 not found."
    fi

    cp -r ${2}/$1 ${3}/$1 || exit_msg "Failed to execute command: cp -r ${2}/$1 ${3}/$1"
}

read_common_input(){

    # General
    LOGS_DIR='/logs'

    while test $# -gt 0
    do
        case "$1" in
            # general
            --logs-dir) full_path $2 && LOGS_DIR=$2 ;;
        esac
        shift
    done

}

