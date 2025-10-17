vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/vim.vim
#^ already done previously

# Vim
setlocal syntax=ON
#^ setlocal fo-=t fo+=croql
setlocal formatoptions-=cro  # don't auto comment new lines
# setlocal number
# setlocal cursorline
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
  inoremap <buffer> <nowait> <CR> <Plug>(autoendstructs-end)
endif

# undo
b:undo_ftplugin = 'setlocal syntax< formatoptions< nowrap< showbreak< tabstop< softtabstop< shiftwidth< shiftround< expandtab< matchpairs< textwidth< tags<'
b:undo_ftplugin ..= ' | silent! iunmap <buffer> <CR>'
