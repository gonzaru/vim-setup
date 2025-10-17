vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/text.vim
#^ already done previously

# text
setlocal syntax=OFF
setlocal ignorecase
setlocal infercase
setlocal wrap
setlocal showbreak=>\ 

# undo
b:undo_ftplugin = 'setlocal syntax< ignorecase< infercase< wrap< showbreak<'
