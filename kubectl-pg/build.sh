#!/bin/sh
cd "$(dirname "$0")" >/dev/null 2>&1 || exit
go mod tidy
CGO_ENABLED=0 go build -trimpath -ldflags "-extldflags -static -w -s" -o "${1:-$GOPATH/bin/${PWD##*/}}"
