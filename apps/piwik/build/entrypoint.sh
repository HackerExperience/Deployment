#!/bin/sh 

export PIWIK_VERSION=2.16.0

cd /var/www && \
    wget http://builds.piwik.org/piwik-${PIWIK_VERSION}.tar.gz && \
    tar -xzf piwik-${PIWIK_VERSION}.tar.gz && \
    rm piwik-${PIWIK_VERSION}.tar.gz && \
    mv piwik/* . && \
    rm -r piwik && \
    chown -R piwik:piwik /var/www && \
    chmod 0770 /var/www/tmp && \
    chmod 0770 /var/www/config && \
    chmod 0600 /var/www/config/* && \
    rm /var/www/index.html
