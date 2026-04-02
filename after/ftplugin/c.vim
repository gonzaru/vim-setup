vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/c.vim
#^ already done previously

# C
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
setlocal cscopetag
setlocal cscopetagorder=0
setlocal iskeyword=a-z,A-Z,48-57,_  # see 'complete'
#^ setlocal omnifunc=ccomplete#Complete
if get(g:, "lsp_enabled")
  setlocal omnifunc=lsp#OmniFunc
  # setlocal complete^=o^10
  if &autocomplete || get(g:, "complementum_enabled")
    # inoremap <buffer> <nowait> <silent> <expr> . ".\<C-x>\<C-o>"
    # trigger for '.'
    inoremap <buffer> <nowait> <silent> <expr> . (col('.') > 1 && getline('.')[col('.') - 2] =~ '\k') ? ".\<C-x>\<C-o>" : "."
    # trigger for '->'
    inoremap <buffer> <nowait> <silent> <expr> > (col('.') > 2 && getline('.')[col('.') - 2] == '-' && getline('.')[col('.') - 3] =~ '\k') ? ">\<C-x>\<C-o>" : ">"
  endif
endif

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap< showbreak< tabstop< softtabstop< shiftwidth< shiftround< expandtab< cscopetag< cscopetagorder< iskeyword<'
