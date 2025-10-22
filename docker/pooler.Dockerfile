FROM alpine:3.23 AS builder
# Inspiration from https://github.com/edoburu/docker-pgbouncer/blob/master/Dockerfile
RUN apk add --no-cache autoconf automake c-ares-dev curl gcc libc-dev libevent-dev libtool make openssl-dev pandoc pkgconf-dev && \
  curl -sL https://www.pgbouncer.org/downloads/files/1.25.1/pgbouncer-1.25.1.tar.gz | tar -xzv && \
  cd pgbouncer-* && \
  curl -sL https://github.com/pgbouncer/pgbouncer/archive/master.tar.gz | tar -xzv --strip-components=1 && \
  ./configure --prefix=/usr/local && make && make install && ls -lt
FROM registry.opensource.zalan.do/acid/pgbouncer:master-32 AS pgbouncer
RUN sed -i -E 's~(_tls_sslmode =).+~\1 prefer~g;s~(_tls_protocols =).+~\1 all~;s~(^stats_users_.+)~# \1~' /etc/pgbouncer/pgbouncer.ini.tmpl
FROM scratch AS cache
COPY --from=builder /usr/local/bin/pgbouncer /bin/pgbouncer
COPY --from=pgbouncer /entrypoint.sh /entrypoint.sh
COPY --from=pgbouncer /etc/pgbouncer/auth_file.txt.tmpl /etc/pgbouncer/auth_file.txt.tmpl
COPY --from=pgbouncer /etc/pgbouncer/pgbouncer.ini.tmpl /etc/pgbouncer/pgbouncer.ini.tmpl
FROM alpine:3.23
COPY --from=cache / /
RUN apk --no-cache add libevent openssl c-ares gettext ca-certificates postgresql-client && \
  addgroup -S pgbouncer && adduser -S pgbouncer && mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer && \
  chown -R pgbouncer:pgbouncer /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer /etc/ssl/certs
USER pgbouncer:pgbouncer
ENTRYPOINT ["/entrypoint.sh"]