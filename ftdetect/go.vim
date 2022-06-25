" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Go
if executable("go") && executable("gofmt")
  augroup checker_go
  autocmd!
  autocmd BufWinEnter *.go call GOCheck("read")|
    \:call GOVetAsync()
  autocmd BufWritePre *.go call GOCheck("write")
  autocmd BufWritePost *.go call GOVetAsync()
  augroup END
endif
