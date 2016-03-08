FROM he_nginx_extras

RUN apk add --no-cache git

RUN mkdir /phabricator

RUN git clone https://github.com/phacility/libphutil.git /phabricator/libphutil
RUN git clone https://github.com/phacility/arcanist.git /phabricator/arcanist
RUN git clone https://github.com/phacility/phabricator.git /phabricator/phabricator

RUN adduser -HDs /dev/null php

RUN apk add --no-cache \
        php \
        php-cli \
        php-fpm \
        php-opcache \
        php-pdo php-pdo_dblib \
        php-mysql php-mysqli \
        php-gd \
        php-json php-openssl php-ctype php-curl php-iconv \
        php-pcntl php-posix php-openssl

VOLUME /var/run
VOLUME /phabricator

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]

