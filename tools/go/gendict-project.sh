#!/bin/sh

set -eu

gomod="$(go env GOMOD)"
if [ "$gomod" = "/dev/null" ]; then
  echo "error: go env GOMOD failed"
  exit 1
fi
cd "$(dirname "$gomod")"
go run ~/.vim/tools/go/gendict.go
