" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/php.vim
" PHP
syntax on
" setlocal signcolumn=auto
setlocal number
setlocal cursorline
setlocal matchpairs-=<:>
setlocal nowrap
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftround
setlocal shiftwidth=4
setlocal expandtab
setlocal makeprg=php\ -lq\ %
call matchadd('ColorColumn', '\%120v', 10)
setlocal omnifunc=phpcomplete#CompletePHP
setlocal suffixesadd+=.tpl.php
