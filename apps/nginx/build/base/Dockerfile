FROM he_base

# Create www-data user
RUN adduser -HDs /dev/null www-data

# Required to compile Nginx.
# linux-headers is required for file-aio support
RUN apk add --no-cache \
    libxml2-dev \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    linux-headers \
    alpine-sdk \
    pcre curl # Both required at runtime

ADD install_nginx.sh ./install_nginx.sh

# Call installation script
RUN chmod +x ./install_nginx.sh
RUN ./install_nginx.sh $MODULES_PATH $NGINX_VERSION

# Remove compile-time dependencies
RUN apk del --purge alpine-sdk pcre-dev zlib-dev openssl-dev linux-headers

# Clean-up
RUN rm -rf /build && rm -rf /root/nginx/*

VOLUME /var/log /etc/nginx

EXPOSE 80 443

CMD ["nginx"]
