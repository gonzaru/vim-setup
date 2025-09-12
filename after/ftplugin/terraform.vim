vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(b:, "did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/terraform.vim
#^ already done previously

# terraform
setlocal syntax=ON
if get(g:, "lsp_enabled")
  setlocal omnifunc=lsp#OmniFunc
endif
