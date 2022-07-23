vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists("b:current_syntax_after")
  finish
endif
b:current_syntax_after = 1

# see $VIMRUNTIME/syntax/python.vim

# Python
syntax region Comment start=/'''/ end=/'''/
syntax region Comment start=/"""/ end=/"""/
