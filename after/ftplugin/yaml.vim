vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

if exists("b:did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = 1

# see $VIMRUNTIME/ftplugin/yaml.vim
#^ already done previously

# YAML
setlocal syntax=on
#^ setlocal formatoptions-=t
# setlocal signcolumn=auto
setlocal number
setlocal cursorline
setlocal nowrap
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab