vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_git") || !get(g:, "git_enabled")
  finish
endif
b:did_ftplugin_git = true

# Git
setlocal statusline=[git]:%<%{!empty(git#GitPrevFile())\ ?\ git#GitPrevFile()->fnamemodify(':~')\ :\ 'none'}\ %h%q%w%m%r%=%{&ft}\ %{&fenc}[%{&ff}]%{get(g:,'statusline_full','')}\ %-15.(%l,%c%V%)\ %P
setlocal winfixheight
setlocal winfixwidth
setlocal noconfirm
setlocal number
setlocal cursorline
setlocal nocursorcolumn
setlocal nowrap
setlocal nospell
setlocal nolist
setlocal buftype=nofile
setlocal noswapfile
setlocal buflisted
setlocal syntax=on
if get(g:, 'git_no_mappings') == 0
  nnoremap <buffer> <nowait> <silent> <CR> <Plug>(git-do-action))
  nnoremap <buffer> <nowait> <silent> gA <Plug>(git-add-file)
  nnoremap <buffer> <nowait> <silent> gb <Plug>(git-blame)
  nnoremap <buffer> <nowait> <silent> gB <Plug>(git-blame-short)
  nnoremap <buffer> <nowait> <silent> gC <Plug>(git-checkout-file)
  nnoremap <buffer> <nowait> <silent> gd <Plug>(git-diff-file)
  nnoremap <buffer> <nowait> <silent> gh <Plug>(git-help)
  nnoremap <buffer> <nowait> <silent> H <Plug>(git-help)
  nnoremap <buffer> <nowait> <silent> gl <Plug>(git-log-file)
  nnoremap <buffer> <nowait> <silent> gL <Plug>(git-log-one-file)
  nnoremap <buffer> <nowait> <silent> gR <Plug>(git-restore-staged-file)
  nnoremap <buffer> <nowait> <silent> gs <Plug>(git-status-file)
  nnoremap <buffer> <nowait> <silent> gS <Plug>(git-show-file)
endif
