vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/indent/python.vim
#^ already done previously

# Python
#^ setlocal nolisp
#^ setlocal autoindent
setlocal smartindent

# undo
b:undo_indent = 'setlocal smartindent<'
