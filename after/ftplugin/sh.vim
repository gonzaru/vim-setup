vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists("b:did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = 1

# see $VIMRUNTIME/ftplugin/sh.vim
#^ already done previously

# SH
# :help ft-posix-syntax
if getline(1) =~ "bash"
  g:is_bash = 1
else
  g:is_posix = 1
endif
setlocal syntax=on
# setlocal signcolumn=auto
setlocal number
setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
setlocal makeprg=sh\ -n\ %
if get(g:, "autoendstructs_enabled")
  if empty(mapcheck("<CR>", "i"))
    inoremap <buffer><CR> <Plug>(autoendstructs-end)
  endif
endif
matchadd('ColorColumn', '\%120v', 10)
