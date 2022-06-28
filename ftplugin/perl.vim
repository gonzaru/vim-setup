" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/perl.vim
" Perl
syntax on
setlocal formatoptions-=t
setlocal signcolumn=yes
setlocal number
setlocal cursorline
setlocal matchpairs-=<:>
setlocal nowrap
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal expandtab
setlocal keywordprg=perldoc\ -f
setlocal makeprg=perl\ -c\ %
call matchadd('ColorColumn', '\%120v', 10)
