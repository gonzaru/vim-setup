" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Python
if get(g:, "checker_enabled")
  if executable("python3") && executable("pep8")
    augroup checker_python
    autocmd!
    " autocmd DiffUpdated FileType python let b:checker_enabled=0
    autocmd BufWinEnter,FileType python if !&diff && !exists('b:fugitive_type') | call PYCheck("read") | call PYPep8Async() | endif
    autocmd FileType python autocmd BufWritePre <buffer> call PYCheck("write")
    autocmd FileType python autocmd BufWritePost <buffer> call PYPep8Async()
    augroup END
  endif
endif
