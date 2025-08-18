#!/bin/sh

set -eu

out="${1:-tags}"  # ./tags

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
