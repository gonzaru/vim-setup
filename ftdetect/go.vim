" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Go
autocmd BufWinEnter *.go call GOCheck("read")|
  \:call GOVetAsync()
autocmd BufWritePre *.go call GOCheck("write")
autocmd BufWritePost *.go call GOVetAsync()
