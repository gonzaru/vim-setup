vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(b:, "did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/text.vim
#^ already done previously

# text
setlocal syntax=off
setlocal ignorecase
setlocal infercase
setlocal wrap
setlocal showbreak=>\ 
