#!/bin/sh

set -eu

go run ~/.vim/tools/go/gendict.go -stdout ~/.vim/dict/go/go-stdlib.dict
