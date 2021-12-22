" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" sh
if has("python3") && (executable("sh") || executable("bash")) && executable("shellcheck")
  autocmd BufWinEnter,FileType sh call SHCheck("read")|
    \:call SHShellCheckAsync()
  autocmd FileType sh autocmd BufWritePre <buffer> call SHCheck("write")
  autocmd FileType sh autocmd BufWritePost <buffer> call SHShellCheckAsync()
endif
