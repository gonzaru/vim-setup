" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" sh
if (executable("sh") || executable("bash")) && executable("shellcheck")
  augroup checker_sh
  autocmd!
  autocmd BufWinEnter,FileType sh call SHCheck("read")|
    \:call SHShellCheckAsync()
  autocmd FileType sh autocmd BufWritePre <buffer> call SHCheck("write")
  autocmd FileType sh autocmd BufWritePost <buffer> call SHShellCheckAsync()
  augroup END
endif
