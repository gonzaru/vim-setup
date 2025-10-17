vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/tmux.vim
#^ already done previously

# tmux
setlocal syntax=ON

# undo
b:undo_ftplugin = 'setlocal syntax<'
