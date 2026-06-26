FROM alpine:latest
ARG TARGETARCH
COPY $TARGETARCH/* /

# We need root certificates to deal with teams api over https
RUN apk -U upgrade --no-cache && \
  apk --no-cache add bash curl ca-certificates && \
  addgroup -g 1000 pgo && adduser -D -u 1000 -G pgo -g 'Postgres Operator' pgo

USER pgo:pgo

ENTRYPOINT ["/postgres-operator"]
