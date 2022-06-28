" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/c.vim
" C
syntax on
setlocal formatoptions-=t
setlocal number
setlocal cursorline
setlocal matchpairs-=<:>
setlocal nowrap
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
setlocal cscopetag
setlocal cscopetagorder=0
setlocal omnifunc=ccomplete#Complete
