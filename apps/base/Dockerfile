FROM gliderlabs/alpine:3.3

# Install essential stuff
RUN apk add --no-cache wget openssl nano gzip ca-certificates curl

# A place where images can upload build scripts
RUN mkdir /build
WORKDIR /build

# Install dumb-init
RUN wget -O /usr/sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.0/dumb-init_1.0.0_amd64
RUN chmod +x /usr/sbin/dumb-init

# Set dumb-init as entrypoint
ENTRYPOINT ["/usr/sbin/dumb-init"]
CMD ["help"]
