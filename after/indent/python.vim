vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists("b:did_indent_after")
  finish
endif
b:did_indent_after = 1

# see $VIMRUNTIME/indent/python.vim
#^ already done previously

# Python
#^ setlocal nolisp
#^ setlocal autoindent
setlocal smartindent
