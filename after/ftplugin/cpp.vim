vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/cpp.vim
#^ already done previously

# C++
setlocal syntax=ON
#^ setlocal formatoptions-=t
# setlocal number
# setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
setlocal matchpairs-=<:>
setlocal cscopetag
setlocal cscopetagorder=0
#^ setlocal omnifunc=cppcomplete#Complete

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap< showbreak< tabstop< softtabstop< shiftwidth< shiftround< expandtab< matchpairs< cscopetag< cscopetagorder<'
