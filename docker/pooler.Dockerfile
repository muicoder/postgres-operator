FROM alpine:latest AS builder
# Inspiration from https://github.com/edoburu/docker-pgbouncer/blob/master/Dockerfile
RUN apk add --no-cache autoconf automake c-ares-dev curl gcc libc-dev libevent-dev libtool make openssl-dev pandoc pkgconf-dev && \
  curl -sL https://www.pgbouncer.org/downloads/files/1.25.2/pgbouncer-1.25.2.tar.gz | tar -xzv && \
  cd pgbouncer-* && \
  curl -sL https://github.com/pgbouncer/pgbouncer/archive/master.tar.gz | tar -xzv --strip-components=1 && \
  ./configure --prefix=/usr/local && make && make install && ls -lt
FROM ghcr.io/zalando/postgres-operator/pgbouncer:v2.0.1 AS pgbouncer
RUN sed -i -E 's~(_tls_sslmode =).+~\1 prefer~g;s~(_tls_protocols =).+~\1 all~;s~(^stats_users_.+)~# \1~' /etc/pgbouncer/pgbouncer.ini.tmpl
FROM scratch AS cache
COPY --from=builder /usr/local/bin/pgbouncer /bin/pgbouncer
COPY --from=pgbouncer /entrypoint.sh /entrypoint.sh
COPY --from=pgbouncer /etc/pgbouncer/pgbouncer.ini.tmpl /etc/pgbouncer/pgbouncer.ini.tmpl
FROM alpine:latest
COPY --from=cache / /
RUN apk -U upgrade --no-cache && \
  apk --no-cache add bash c-ares ca-certificates gettext libevent openssl postgresql-client && \
  addgroup -g 101 -S pgbouncer && adduser -u 100 -S pgbouncer -G pgbouncer && \
  mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer /etc/ssl/certs && \
  chown -R pgbouncer:pgbouncer /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer /etc/ssl/certs
USER pgbouncer:pgbouncer
ENTRYPOINT ["/entrypoint.sh"]
