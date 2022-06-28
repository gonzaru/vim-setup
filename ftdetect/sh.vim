" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" sh
if get(g:, "checker_enabled")
  if (executable("sh") || executable("bash")) && executable("shellcheck")
    augroup checker_sh
    autocmd!
    " autocmd DiffUpdated FileType sh let b:checker_enabled=0
    autocmd BufWinEnter,FileType sh if !&diff && !exists('b:fugitive_type') | call SHCheck("read") | call SHShellCheckAsync() | endif
    autocmd FileType sh autocmd BufWritePre <buffer> call SHCheck("write")
    autocmd FileType sh autocmd BufWritePost <buffer> call SHShellCheckAsync()
    augroup END
  endif
endif
