#!/bin/sh

set -eu

lockfile="/tmp/${USER}-vim-go-gendict-project.lock"

# exit if already running
os="$(uname -s)"
case "$os" in
  Linux)
    exec 9>"$lockfile"
    if ! flock -n 9; then
      echo "dict generation already running, exiting" >&2
      exit 1
    fi
    ;;
  Darwin|*BSD)
    if ! lockf -t 0 "$lockfile" true 2>/dev/null; then
      echo "dict generation already running, exiting" >&2
      exit 1
    fi
    ;;
  *)
    echo "unsupported system: $os" >&2
    exit 1
    ;;
esac

gomod="$(go env GOMOD)"
if [ "$gomod" = "/dev/null" ]; then
  echo "error: go env GOMOD failed"
  exit 1
fi
cd "$(dirname "$gomod")"
go run ~/.vim/tools/go/gendict.go
