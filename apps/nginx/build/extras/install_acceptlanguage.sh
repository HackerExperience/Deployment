#!/bin/sh
MODULES_PATH=/root/nginx
cd $MODULES_PATH
wget https://github.com/giom/nginx_accept_language_module/archive/master.zip
unzip master.zip && rm master.zip
