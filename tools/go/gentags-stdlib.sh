#!/bin/sh

set -eu

if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: go not found in PATH"
  exit 1
fi
if ! command -v ctags >/dev/null 2>&1; then
  echo "ERROR: ctags (Universal Ctags) not found"
  exit 1
fi

goroot="$(go env GOROOT)"
if [ ! -d "$goroot/src" ]; then
  echo "ERROR: $goroot/src not found"
  exit 1
fi

out="${1:-${HOME}/.vim/tags/go/go-stdlib.tags}"

# --kinds-Go=+f+m+t+i \
# --fields=+nksSa \
cd "$goroot/src" &&
ctags -R \
  -f "$out" \
  --tag-relative=yes \
  --languages=Go \
  --kinds-Go=+fpstuv \
  --fields=+KStn \
  --extras=+q \
  --pseudo-tags=-TAG_PROC_CWD \
  --exclude='*_test.go' \
  --exclude='importdecl0b.go' \
  --exclude='issue43190.go'
