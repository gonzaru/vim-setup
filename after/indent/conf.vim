vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
# if get(b:, "did_indent_after")
#   finish
# endif
# b:did_indent_after = true

# conf
setlocal autoindent

# undo
b:undo_indent = 'setlocal autoindent<'
