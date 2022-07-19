" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftdetect_python") || get(g:, "checker_enabled") == 0
  finish
endif
let b:did_ftdetect_python = 1

" Python
if executable("python3") && executable("pep8")
  augroup checker_python
  autocmd!
  " autocmd DiffUpdated FileType python let b:checker_enabled=0
  autocmd BufWinEnter,FileType python if &filetype ==# "python" && !&diff && !exists('b:fugitive_type') | call checker#PYCheck("read") | call checker#PYPep8Async() | endif
  autocmd FileType python autocmd BufWritePre <buffer> call checker#PYCheck("write")
  autocmd FileType python autocmd BufWritePost <buffer> call checker#PYPep8Async()
  augroup END
endif
