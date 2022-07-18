" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded or checker is not enabled
if get(g:, 'loaded_checker') == 1 || get(g:, 'checker_enabled') == 0 || &cp
  finish
endif
let g:loaded_checker = 1

" SH
if (executable("sh") || executable("bash")) && executable("shellcheck")
  augroup checker_sh
  autocmd!
  " autocmd DiffUpdated FileType sh let b:checker_enabled=0
  autocmd BufWinEnter,FileType sh if !&diff && !exists('b:fugitive_type') | call checker#SHCheck("read") | call checker#SHShellCheckAsync() | endif
  autocmd FileType sh autocmd BufWritePre <buffer> call checker#SHCheck("write")
  autocmd FileType sh autocmd BufWritePost <buffer> call checker#SHShellCheckAsync()
  augroup END
endif

" Python
if executable("python3") && executable("pep8")
  augroup checker_python
  autocmd!
  " autocmd DiffUpdated FileType python let b:checker_enabled=0
  autocmd BufWinEnter,FileType python if !&diff && !exists('b:fugitive_type') | call checker#PYCheck("read") | call checker#PYPep8Async() | endif
  autocmd FileType python autocmd BufWritePre <buffer> call checker#PYCheck("write")
  autocmd FileType python autocmd BufWritePost <buffer> call checker#PYPep8Async()
  augroup END
endif

" Go
if executable("go") && executable("gofmt")
  augroup checker_go
  autocmd!
  " autocmd DiffUpdated *.go let b:checker_enabled=0
  autocmd BufWinEnter *.go if !&diff && !exists('b:fugitive_type') | call checker#GOCheck("read") | call checker#GOVetAsync() | endif
  autocmd BufWritePre *.go call checker#GOCheck("write")
  autocmd BufWritePost *.go call checker#GOVetAsync()
  augroup END
endif

" TODO:
" set mappings
" define mappings
" if get(g:, 'checker_no_mappings') == 0
" endif
