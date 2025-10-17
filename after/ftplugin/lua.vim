vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/lua.vim
#^ already done previously

# lua
setlocal syntax=ON
#^ setlocal formatoptions-=t formatoptions+=croql
#^ setlocal comments=:---,:--
#^ setlocal commentstring=--\ %s
#^ setlocal path-=.
#^ setlocal includeexpr=s:LuaInclude(v:fname)
#^ setlocal suffixesadd=.lua
# setlocal signcolumn=auto
# setlocal number
# setlocal cursorline
setlocal nowrap
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap< tabstop< softtabstop< shiftwidth< shiftround< expandtab<'
