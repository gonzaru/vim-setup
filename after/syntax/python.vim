vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if !empty(get(b:, "current_syntax_after"))
  finish
endif

# see $VIMRUNTIME/syntax/python.vim

# Python
syntax region Comment start=/'''/ end=/'''/
syntax region Comment start=/"""/ end=/"""/

b:current_syntax_after = "python"
