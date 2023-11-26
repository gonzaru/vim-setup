vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists("b:did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/perl.vim
#^ already done previously

# Perl
setlocal syntax=on
#^ setlocal formatoptions-=t
# setlocal signcolumn=auto
setlocal number
setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal expandtab
#^ setlocal keywordprg=perldoc\ -f
setlocal makeprg=perl\ -c\ %
matchadd('ColorColumn', '\%120v', 10)
