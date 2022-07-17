" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

"  see $VIMRUNTIME/ftplugin/vim.vim
" vim
syntax on
setlocal formatoptions-=t
setlocal formatoptions-=cro " (see also after/ftplugin/vim.vim when b:did_ftplugin is not used)
setlocal number
setlocal cursorline
setlocal nowrap
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
setlocal textwidth=0
setlocal tags=$HOME/.vim/tags
setlocal keywordprg=:help
if get(g:, "autoendstructs_enabled")
  inoremap <buffer><CR> <Plug>(autoendstructs-end)
endif
