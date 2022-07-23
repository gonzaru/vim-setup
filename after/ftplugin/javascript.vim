vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists("b:did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = 1

# see $VIMRUNTIME/ftplugin/javascript.vim
#^ already done previously

# JavaScript
setlocal syntax=on
#^ setlocal formatoptions-=t
# setlocal signcolumn=auto
setlocal number
setlocal cursorline
#^ setlocal suffixesadd+=.js,.jsx,.es,.es6,.cjs,.mjs,.jsm,.vue,.json
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal expandtab
#^ setlocal omnifunc=javascriptcomplete#CompleteJS
setlocal makeprg=node\ --check\ %
