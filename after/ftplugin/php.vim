vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(b:, "did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/php.vim
#^ already done previously

# PHP
setlocal syntax=on
# setlocal signcolumn=auto
# setlocal number
# setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftround
setlocal shiftwidth=4
setlocal expandtab
setlocal makeprg=php\ -lq\ %
#^ setlocal omnifunc=phpcomplete#CompletePHP
setlocal suffixesadd+=.tpl.php
# matchadd('ColorColumn', '\%120v', 10)
if g:misc_enabled
  misc#MatchAdd({'group': 'ColorColumn', 'pattern': '\%120v', 'priority': 10})
endif
