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
CMD ["/bin/sh" "-c" "mysqld", "--user=mysql"]
