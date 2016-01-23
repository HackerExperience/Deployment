#!/bin/sh

MODULES_PATH=/root/nginx
NGINX=1.9.9

mkdir -p $MODULES_PATH && cd $MODULES_PATH

wget -qO- http://nginx.org/download/nginx-${NGINX}.tar.gz | tar xvz

cd nginx-${NGINX}

# Change the config as needed.

./configure \
                                                                                \
    `# Paths`                                                                   \
    --prefix=/etc/nginx                                                         \
    --sbin-path=/usr/sbin/nginx                                                 \
    --conf-path=/etc/nginx/nginx.conf                                           \
    --pid-path=/var/run/nginx.pid                                               \
    --lock-path=/var/run/nginx.lock                                             \
    --error-log-path=/var/log/nginx/error.log                                   \
    --http-log-path=/var/log/nginx/access.log                                   \
    --http-client-body-temp-path=/var/cache/nginx/client_temp                   \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp                          \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp                      \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp                          \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp                            \
                                                                                \
    `# Ownership data. Don't use root.`                                         \
    --user=www-data                                                             \
    --group=www-data                                                            \
                                                                                \
    `# We'll stick with epool so we don't need poll/select`                     \
    --without-poll_module                                                       \
    --without-select_module                                                     \
                                                                                \
    `# SSL support`                                                             \
    --with-http_ssl_module                                                      \
                                                                                \
    `# HTTP2 support`                                                           \
    --with-http_v2_module                                                       \
                                                                                \
    `# RealIP module`                                                           \
    --with-http_realip_module                                                   \
                                                                                \
    `# Uncomment to enable GeoIP support`                                       \
    `# --with-http_geoip_module`                                                \
                                                                                \
    `# Gunzip`                                                                  \
    --with-http_gunzip_module                                                   \
                                                                                \
    `# Enable Gzip static`                                                      \
    --with-http_gzip_static_module                                              \
                                                                                \
    `# IPv6 support`                                                            \
    --with-ipv6                                                                 \
                                                                                \
    `# Increase concurrency`                                                    \
    --with-threads                                                              \
    --with-file-aio                                                             \
                                                                                \
    `# We use perl for minification...`                                         \
    --with-http_perl_module                                                     \
                                                                                \
    `# Disabling stuff I don't think we'll use`                                 \
    --without-http_charset_module                                               \
    --without-http_ssi_module                                                   \
    --without-http_userid_module                                                \
    --without-http_autoindex_module                                             \
    --without-http_map_module                                                   \
    --without-http_split_clients_module                                         \
    --without-http_referer_module                                               \
    --without-http_memcached_module                                             \
    --without-http_empty_gif_module                                             \
    --without-http_browser_module                                               \
    --without-mail_pop3_module                                                  \
    --without-mail_imap_module                                                  \
    --without-mail_smtp_module                                                  \
                                                                                \
    `# Upstream might be useful in some cases.`                                 \
    `# Comment the lines below if you plan to have multiple application`        \
    `# servers behind nginx.`                                                   \
    --without-http_upstream_hash_module                                         \
    --without-http_upstream_ip_hash_module                                      \
    --without-http_upstream_least_conn_module                                   \
    --without-http_upstream_keepalive_module                                    \
    --without-http_upstream_zone_module                                         \
                                                                                \
    `# Toggle comments if you plan to use Stream TCP Proxy`                     \
    `# --with-stream`                                                           \
    --without-stream_limit_conn_module                                          \
    --without-stream_access_module                                              \
    --without-stream_upstream_hash_module                                       \
    --without-stream_upstream_least_conn_module                                 \
    --without-stream_upstream_zone_module                                       \
                                                                                \
    `# Stuff that could have been disabled, but we choose not to.`              \
                                                                                \
    `# Limit connections/requests per IP. Useful.`                              \
    `#--without-http_limit_conn_module`                                         \
    `#--without-http_limit_req_module`                                          \
                                                                                \
    `# Allow/deny (range of)IPs`                                                \
    `#--without-http_access_module`                                             \
                                                                                \
    `# Support for HTTP Basic Auth`                                             \
    `#--without-http_auth_basic_module`                                         \
                                                                                \
    `# Rewrite module is very useful for changing/regex URIs`                   \
    `#--without-http_rewrite_module`                                            \
                                                                                \
    `# Keep basic proxy support`                                                \
    `#--without-http_proxy_module`                                              \
                                                                                \
                                                                                \
                                                                                \
    `# The following are specific server support. Change as needed.`            \
    `# Uncomment if you don't plan to use PHP`                                  \
    `#--without-http_fastcgi_module`                                            \
                                                                                \
    `# Uncomment if you don't plan to use Python with uWSGI`                    \
    --without-http_uwsgi_module                                                 \
                                                                                \
    `# Comment if you need SCGI`                                                \
    --without-http_scgi_module                                                  \
                                                                                \
    `# 3rd-party Modules (see previous section; uncomment if you need them)`    \
                                                                                \
    `# nginx_accept_language module`                                            \
    --add-module=${MODULES_PATH}/nginx_accept_language_module-master/           \
                                                                                \
    `# Pagespeed support`                                                       \
    --add-module=${MODULES_PATH}/nginx-http-concat-master                       \
                                                                                \
    `# Mod Security`                                                            \
    --add-module=${MODULES_PATH}/modsecurity/nginx/modsecurity                  \
                                                                                \
    `# End of config`

make && make install
