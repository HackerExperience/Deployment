FROM he_base

RUN adduser -HDs /dev/null php

RUN apk add --no-cache \
        php \
        php-cli \
        php-fpm \
        php-opcache \
        php-pdo php-pdo_dblib \
        php-mysql php-mysqli \
        php-gd 

VOLUME /var/run

CMD ["php-fpm"]
