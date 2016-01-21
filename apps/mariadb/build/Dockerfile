FROM he_base

# Install from APK
RUN apk add --no-cache mariadb mariadb-client bash

# Setup mysql dirs and permissions
RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql
RUN chown -R mysql:mysql /run/mysqld

# Cleanup
RUN rm -rf /build && rm -rf /root/* && rm -rf /etc/apk/cache/*

EXPOSE 3306

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Start
CMD ["mysqld_safe", "--user=mysql"]

# TODO: fix this, entrypoint.sh makes dumb-init useless
# PID   USER     TIME   COMMAND
#    1 root       0:00 {entrypoint.sh} /bin/bash /entrypoint.sh mysqld --user=mysql
#  164 root       0:00 dumb-init /bin/sh -c mysqld --user=mysql
#  165 root       0:00 /bin/sh -c mysqld --user=mysql
#  166 mysql      0:02 mysqld
