vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

if exists("b:did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = 1

# see $VIMRUNTIME/ftplugin/vim.vim
#^ already done previously

# Vim
setlocal syntax=on
#^ setlocal formatoptions-=t
setlocal formatoptions-=cro  # don't auto comment new lines
setlocal number
setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
setlocal matchpairs+=<:>
setlocal textwidth=0
setlocal tags=$HOME/.vim/tags
#^ setlocal keywordprg=:help
if get(g:, "autoendstructs_enabled")
  if empty(mapcheck("<CR>", "i"))
    inoremap <buffer><CR> <Plug>(autoendstructs-end)
  endif
endif