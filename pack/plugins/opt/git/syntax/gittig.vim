vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(b:, "current_syntax")
  finish
endif

# git syntax
setlocal syntax=git

b:current_syntax = "git"
