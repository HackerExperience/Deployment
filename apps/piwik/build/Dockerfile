FROM he_base

# Create piwik user and group
RUN adduser -DHs /dev/null piwik piwik

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME /var/www


