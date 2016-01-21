#!/bin/bash

set -e

source $(dirname $0)/../../common.sh
source $(dirname $0)/../mariadb/mariadb.sh
source $(dirname $0)/../nginx/nginx.sh
source $(dirname $0)/../php5/php5.sh

deploy_mariadb "$@"
deploy_nginx "$@"
deploy_php5 "$@"
