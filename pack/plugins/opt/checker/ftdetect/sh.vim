" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftdetect_sh") || get(g:, "checker_enabled") == 0
  finish
endif
let b:did_ftdetect_sh = 1

" SH
if (executable("sh") || executable("bash")) && executable("shellcheck")
  augroup checker_sh
  autocmd!
  " autocmd DiffUpdated FileType sh let b:checker_enabled=0
  autocmd BufWinEnter,FileType sh if &filetype ==# "sh" && !&diff && !exists('b:fugitive_type') | call checker#SHCheck("read") | call checker#SHShellCheckAsync() | endif
  autocmd FileType sh autocmd BufWritePre <buffer> call checker#SHCheck("write")
  autocmd FileType sh autocmd BufWritePost <buffer> call checker#SHShellCheckAsync()
  augroup END
endif
