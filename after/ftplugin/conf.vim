vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/conf.vim
#^ already done previously

# conf
setlocal syntax=OFF
setlocal nowrap

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap<'
