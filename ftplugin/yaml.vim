" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/yaml.vim
" YAML
syntax on
setlocal formatoptions-=t
setlocal signcolumn=yes
setlocal number
setlocal cursorline
setlocal matchpairs-=<:>
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
