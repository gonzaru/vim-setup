" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Python
if executable("python3") && executable("pep8")
  augroup checker_python
  autocmd!
  autocmd BufWinEnter,FileType python call PYCheck("read")|
    \:call PYPep8Async()
  autocmd FileType python autocmd BufWritePre <buffer> call PYCheck("write")
  autocmd FileType python autocmd BufWritePost <buffer> call PYPep8Async()
  augroup END
endif
