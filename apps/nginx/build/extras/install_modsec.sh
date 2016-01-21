#!/bin/sh
MODULES_PATH=/root/nginx
MS_VERSION=2.9.0
cd $MODULES_PATH    
wget -qO- https://www.modsecurity.org/tarball/${MS_VERSION}/modsecurity-${MS_VERSION}.tar.gz | tar xvz
mv modsecurity-${MS_VERSION} modsecurity && cd modsecurity
./configure --enable-standalone-module --disable-mlogc
make
