FROM he_nginx_base

# Required to compile Nginx.
# linux-headers is required for file-aio support
RUN apk add --no-cache \
    libxml2-dev \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    linux-headers \
    alpine-sdk \
    perl-dev

# Required by mod_security
RUN apk add --no-cache \
    apache2-dev \
    curl-dev \
    apr apr-util

# Required by minification script (runtime)
RUN apk add --no-cache perl

# Copy files to container
ADD install_acceptlanguage.sh ./install_acceptlanguage.sh
ADD install_httpconcat.sh ./install_httpconcat.sh
ADD install_modsec.sh ./install_modsec.sh
ADD install_nginx.sh ./install_nginx.sh 
ADD install_minification.sh ./install_minification.sh

# Install everything
RUN chmod +x ./install_*
RUN ./install_acceptlanguage.sh
RUN ./install_httpconcat.sh
RUN ./install_modsec.sh 
RUN ./install_nginx.sh
RUN ./install_minification.sh

# Remove compile-time dependencies
RUN apk del --purge alpine-sdk pcre-dev zlib-dev openssl-dev linux-headers apache2-dev curl-dev perl-dev

# Clean-up
RUN rm -rf /build && rm -rf /root/nginx/*
