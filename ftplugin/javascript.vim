" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if is already loaded
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/javascript.vim
" JavaScript
syntax on
setlocal formatoptions-=t
setlocal signcolumn=yes
setlocal number
setlocal cursorline
setlocal matchpairs-=<:>
setlocal suffixesadd+=.js,.jsx,.es,.es6,.cjs,.mjs,.jsm,.vue,.json
setlocal nowrap
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal expandtab
setlocal omnifunc=javascriptcomplete#CompleteJS
setlocal makeprg=node\ --check\ %
