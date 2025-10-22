FROM alpine:3.23
ARG TARGETARCH
# We need root certificates to deal with teams api over https
RUN apk --no-cache add curl ca-certificates

COPY $TARGETARCH/* /

RUN addgroup -g 1000 pgo
RUN adduser -D -u 1000 -G pgo -g 'Postgres Operator' pgo

USER 1000:1000

ENTRYPOINT ["/postgres-operator"]
