vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/rust.vim
#^ already done previously

# Rust
setlocal syntax=ON
#^ setlocal formatoptions-=t formatoptions+=croqnl
# setlocal signcolumn=auto
# setlocal number
# setlocal cursorline
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
if get(g:, "lsp_enabled")
  setlocal omnifunc=lsp#OmniFunc
  # setlocal complete^=o^10
  if &autocomplete && !get(g:, "complementum_enabled")
    # inoremap <buffer> <nowait> <silent> <expr> . ".\<C-x>\<C-o>"
    inoremap <buffer> <nowait> <silent> <expr> . (getline('.')[col('.') - 2] =~ '\k') ? ".\<C-x>\<C-o>" : "."
  endif
endif

# undo
b:undo_ftplugin = 'setlocal syntax< tabstop< softtabstop< shiftwidth<'
