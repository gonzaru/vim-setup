" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/tmux.vim
" tmux
" syntax off
