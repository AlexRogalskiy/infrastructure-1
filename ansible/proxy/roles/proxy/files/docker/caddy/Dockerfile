# Based on https://github.com/abiosoft/caddy-docker
FROM abiosoft/caddy:builder as builder

# Compile caddy
ARG VERSION="1.0.3"
ARG PLUGINS="jwt,login,cors"
RUN VERSION=${VERSION} PLUGINS=${PLUGINS} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh

# Run caddy using a minimal alpine image
FROM alpine:3.10
RUN apk add --no-cache ca-certificates
COPY --from=builder /install/caddy /usr/bin/caddy

ENTRYPOINT ["caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=true"]
