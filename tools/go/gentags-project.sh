#!/bin/sh

set -eu

out="${1:-tags}"  # ./tags
lockfile="/tmp/vim-go-gentags-project.lock"

# exit if already running
os="$(uname -s)"
case "$os" in
  Linux)
    exec 9>"$lockfile"
    if ! flock -n 9; then
      echo "tags generation already running, exiting" >&2
      exit 1
    fi
    ;;
  Darwin|*BSD)
    if ! lockf -t 0 "$lockfile" true 2>/dev/null; then
      echo "tags generation already running, exiting" >&2
      exit 1
    fi
    ;;
  *)
    echo "unsupported system: $os" >&2
    exit 1
    ;;
esac

# git
if [ -d .git ] || git rev-parse --show-toplevel >/dev/null 2>&1; then
  cd "$(git rev-parse --show-toplevel)"
fi

ctags -R \
  -f "$out" \
  --tag-relative=yes \
  --languages=Go \
  --kinds-Go=+fpstuv \
  --fields=+KStn \
  --extras=+q \
  --pseudo-tags=-TAG_PROC_CWD \
  --exclude='*_test.go' \
  --exclude='.git' \
  --exclude='vendor' \
  --exclude='node_modules'
