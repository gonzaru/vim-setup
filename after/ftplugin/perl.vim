vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
# if get(b:, "did_ftplugin_after")
#   finish
# endif
# b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/perl.vim
#^ already done previously

# Perl
setlocal syntax=ON
#^ setlocal formatoptions-=t
# setlocal signcolumn=auto
# setlocal number
# setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal expandtab
setlocal iskeyword=@,48-57,_,192-255,$,%,@-@,:,#  # see 'complete'
#^ setlocal keywordprg=perldoc\ -f
setlocal makeprg=perl\ -c\ %
# setlocal colorcolumn=120
# matchadd('ColorColumn', '\%120v', 10)
if g:misc_enabled
  misc#MatchAdd({'group': 'ColorColumn', 'pattern': '\%120v', 'priority': 10})
endif

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap< showbreak< tabstop< softtabstop< shiftwidth< shiftround< expandtab< iskeyword< makeprg<'
