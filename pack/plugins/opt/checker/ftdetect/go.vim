" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftdetect_go") || get(g:, "checker_enabled") == 0
  finish
endif
let b:did_ftdetect_go = 1

" Go
if executable("go") && executable("gofmt")
  augroup checker_go
  autocmd!
  " autocmd DiffUpdated *.go let b:checker_enabled=0
  autocmd BufWinEnter *.go if &filetype ==# "go" && !&diff && !exists('b:fugitive_type') | call checker#GOCheck("read") | call checker#GOVetAsync() | endif
  autocmd BufWritePre *.go call checker#GOCheck("write")
  autocmd BufWritePost *.go call checker#GOVetAsync()
  augroup END
endif
