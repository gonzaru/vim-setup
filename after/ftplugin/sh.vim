vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/sh.vim
#^ already done previously

# SH
# :help ft-posix-syntax
if getline(1) =~ "bash"
  b:is_bash = true
else
  b:is_posix = true
endif
setlocal syntax=ON
#^ setlocal formatoptions-=t formatoptions+=croql
setlocal formatoptions-=cro  # don't auto comment new lines
# setlocal signcolumn=auto
# setlocal number
# setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
setlocal makeprg=sh\ -n\ %
# see :help gq (gqip, gggqG, ...). Also :help 'equalprg' (gg=G, ...)
&l:formatprg = $"shfmt -i {&l:shiftwidth} -"
if get(g:, "autoendstructs_enabled")
  inoremap <buffer> <nowait> <CR> <Plug>(autoendstructs-end)
endif
# setlocal colorcolumn=120
# matchadd('ColorColumn', '\%120v', 10)
if g:misc_enabled
  misc#MatchAdd({'group': 'ColorColumn', 'pattern': '\%120v', 'priority': 10})
endif

# undo
b:undo_ftplugin = 'setlocal syntax< formatoptions< nowrap< showbreak< tabstop< softtabstop< shiftwidth< shiftround< expandtab< makeprg< formatprg<'
b:undo_ftplugin ..= ' | silent! iunmap <buffer> <CR>'
b:undo_ftplugin ..= ' | silent! unlet b:is_bash | silent! unlet b:is_posix'
