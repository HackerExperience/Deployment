#!/bin/sh
set -e

. $(dirname $0)/../../common.sh

piwik_rotate(){

    LOG_ARCHIVE_PATH='/log-archive'
    PIWIK_ROTATE_PATH='/piwik-rotate'
    PIWIK_ROTATE_EXTENSION='.piwikrotate'

    while [ $# -gt 0 ]
    do
        case $1 in
            '--rotate-path') PIWIK_ROTATE_PATH=$2 ;;
            '--rotate-ext' ) PIWIK_ROTATE_EXTENSION=$2 ;;
            '--rotate'|'-r') rotate $2 ;;
            '--archive'|'-a') archive $2 ;;
            '--archive-path') LOG_ARCHIVE_PATH=$2 ;;
        esac
        shift
    done

}

rotate(){
    mkdir -p $PIWIK_ROTATE_PATH
    
    log_name=$(echo "$1" | grep -o '[^/]*$')
    # log_path=$(echo "$1" | sed s/$log_name//)

    # Copy permissions on a temporary file
    touch $1.tmp && chown --reference=$1 $1.tmp || exit_msg "Error"

    # Do the switch
    mv $1 ${PIWIK_ROTATE_PATH}/${log_name}${PIWIK_ROTATE_EXTENSION} && 
        mv $1.tmp $1
}

archive(){

    log_name=$(echo "$1" | grep -o '[^/]*$' | sed s/$PIWIK_ROTATE_EXTENSION//)
    log_path=$(echo "$1" | sed s/$log_name//)

    if [ ! -f ${LOG_ARCHIVE_PATH}/$log_name ]; then
        mkdir -p $LOG_ARCHIVE_PATH
        touch $LOG_ARCHIVE_PATH/$log_name
    fi

    cat $1 >> ${LOG_ARCHIVE_PATH}/$log_name && rm -f $1

}

piwik_rotate "$@"
