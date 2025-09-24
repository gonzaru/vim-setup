vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
# if get(b:, "did_ftplugin_after")
#   finish
# endif
# b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/html.vim
#^ already done previously

# HTML
setlocal syntax=ON
#^ setlocal formatoptions-=t formatoptions+=croql
#^ setlocal comments=s:<!--,m:\ \ \ \ ,e:-->
#^ setlocal commentstring=<!--\ %s\ -->
#^ setlocal matchpairs+=<:>
#^ setlocal omnifunc=htmlcomplete#CompleteTags
setlocal nowrap
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap< tabstop< softtabstop< shiftwidth< shiftround< expandtab<'
