vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/make.vim
#^ already done previously

# make
setlocal syntax=ON
setlocal nowrap

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap<'
