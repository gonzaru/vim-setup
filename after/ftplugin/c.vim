vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(b:, "did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/c.vim
#^ already done previously

# C
setlocal syntax=on
#^ setlocal formatoptions-=t
setlocal number
setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
setlocal cscopetag
setlocal cscopetagorder=0
setlocal iskeyword=a-z,A-Z,48-57,_,.,-,>  # see 'complete'
#^ setlocal omnifunc=ccomplete#Complete
