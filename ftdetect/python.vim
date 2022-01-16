" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Python
if executable("python3") && executable("pep8")
  autocmd BufWinEnter,FileType python call PY3Check("read")|
    \:call PY3Pep8Async()
  autocmd FileType python autocmd BufWritePre <buffer> call PY3Check("write")
  autocmd FileType python autocmd BufWritePost <buffer> call PY3Pep8Async()
endif
