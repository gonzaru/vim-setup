vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
# if get(b:, "did_ftplugin_after")
#   finish
# endif
# b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/terraform.vim
#^ already done previously

# terraform
setlocal syntax=ON
if get(g:, "lsp_enabled")
  setlocal omnifunc=lsp#OmniFunc
  # setlocal complete^=o^10
  if &autocomplete && !get(g:, "complementum_enabled")
    # inoremap <buffer> <nowait> <silent> <expr> . ".\<C-x>\<C-o>"
    inoremap <buffer> <nowait> <silent> <expr> . (getline('.')[col('.') - 2] =~ '\k') ? ".\<C-x>\<C-o>" : "."
  endif
endif

# undo
b:undo_ftplugin = 'setlocal syntax< omnifunc< complete<'
