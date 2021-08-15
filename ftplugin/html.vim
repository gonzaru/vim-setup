" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if is already loaded
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/html.vim
" HTML
syntax on
setlocal formatoptions-=t
setlocal matchpairs+=<:>
setlocal omnifunc=htmlcomplete#CompleteTags
