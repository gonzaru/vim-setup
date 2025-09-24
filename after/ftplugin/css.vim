vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
# if get(b:, "did_ftplugin_after")
#   finish
# endif
# b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/css.vim
#^ already done previously

# CSS
setlocal syntax=ON
#^ setlocal formatoptions-=t
#^ setlocal comments=s1:/*,mb:*,ex:*/ commentstring=/*\ %s\ */
#^ setlocal iskeyword+=-
#^ setlocal omnifunc=csscomplete#CompleteCSS
setlocal nowrap
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap< tabstop< softtabstop< shiftwidth< shiftround< expandtab<'
