" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Go
if get(g:, "checker_enabled")
  if executable("go") && executable("gofmt")
    augroup checker_go
    autocmd!
    " autocmd DiffUpdated *.go let b:checker_enabled=0
    autocmd BufWinEnter *.go if !&diff && !exists('b:fugitive_type') | call GOCheck("read") | call GOVetAsync() | endif
    autocmd BufWritePre *.go call GOCheck("write")
    autocmd BufWritePost *.go call GOVetAsync()
    augroup END
  endif
endif
