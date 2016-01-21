#!/bin/sh
MODULES_PATH=/root/nginx
cd $MODULES_PATH
wget https://github.com/alibaba/nginx-http-concat/archive/master.zip
unzip master.zip && rm master.zip
