vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists("b:did_indent_after")
  finish
endif
b:did_indent_after = true

# see $VIMRUNTIME/indent/python.vim
#^ already done previously

# Python
#^ setlocal nolisp
#^ setlocal autoindent
setlocal smartindent
