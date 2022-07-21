" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded or checker is not enabled
if exists('g:loaded_checker') || !get(g:, 'checker_enabled') || &cp
  finish
endif
let g:loaded_checker = 1

" SH
if (executable("sh") || executable("bash")) && executable("shellcheck")
  augroup checker_sh
    autocmd!
    " autocmd DiffUpdated FileType sh let b:checker_enabled=0
    autocmd FileType sh autocmd BufWinEnter <buffer> if !&diff && !exists('b:fugitive_type')
                                                  \|   call checker#SHCheck(expand('<afile>:p'), "read")
                                                  \|   call checker#SHShellCheckAsync(expand('<afile>:p'))
                                                  \| endif
    autocmd FileType sh autocmd BufWritePost <buffer> call checker#SHCheck(expand('<afile>:p'), "write")
                                                   \| call checker#SHShellCheckAsync(expand('<afile>:p'))
  augroup END
endif

" Python
if executable("python3") && executable("pep8")
  augroup checker_python
    autocmd!
    " autocmd DiffUpdated FileType python let b:checker_enabled=0
    autocmd FileType python autocmd BufWinEnter <buffer> if !&diff && !exists('b:fugitive_type')
                                                      \|   call checker#PYCheck(expand('<afile>:p'), "read")
                                                      \|   call checker#PYPep8Async(expand('<afile>:p'))
                                                      \| endif
    autocmd FileType python autocmd BufWritePost <buffer> call checker#PYCheck(expand('<afile>:p'), "write")
                                                       \| call checker#PYPep8Async(expand('<afile>:p'))
  augroup END
endif

" Go
if executable("go") && executable("gofmt")
  augroup checker_go
    autocmd!
    " autocmd DiffUpdated *.go let b:checker_enabled=0
    autocmd FileType go autocmd BufWinEnter <buffer> if !&diff && !exists('b:fugitive_type')
                                                  \|   call checker#GOCheck(expand('<afile>:p'), "read")
                                                  \|   call checker#GOVetAsync(expand('<afile>:p'))
                                                  \| endif
    autocmd FileType go autocmd BufWritePost <buffer> call checker#GOCheck(expand('<afile>:p'), "write")
                                                   \| call checker#GOVetAsync(expand('<afile>:p'))
  augroup END
endif

" TODO:
" set mappings
" define mappings
" if get(g:, 'checker_no_mappings') == 0
" endif
