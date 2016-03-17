#!/bin/sh
set -e

piwik_rotate(){

    PIWIK_ROTATE_PATH='/piwik-rotate'
    PIWIK_ROTATE_EXTENSION='.piwikrotate'

    while [ $# -gt 0 ]
    do
        case $1 in
            '--rotate-path') PIWIK_ROTATE_PATH=$2 ;;
            '--rotate-ext' ) PIWIK_ROTATE_EXTENSION=$2 ;;
            '--rotate'|'-r') do_rotate $2 ;;
        esac
        shift
    done

}

do_rotate(){
    mkdir -p $PIWIK_ROTATE_PATH
    
    # log_name=$(echo "$1" | grep -o '[^/]*$')
    # log_path=$(echo "$1" | sed s/$log_name//)

    # Copy permissions on a temporary file
    touch $1.tmp && chown --reference=$1 $1.tmp

    # Do the switch
    mv $1 ${PIWIK_ROTATE_PATH}/${log_name}${PIWIK_ROTATE_EXTENSION} && 
        mv $1.tmp $1
}

piwik_rotate "$@"
