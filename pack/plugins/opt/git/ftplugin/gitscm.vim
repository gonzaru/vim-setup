vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_git") || !get(g:, "git_enabled")
  finish
endif
b:did_ftplugin_git = true

# Git
setlocal syntax=ON
setlocal statusline=[git]:%<%{!empty(git#GitPrevFile())\ ?\ git#GitPrevFile()->fnamemodify(':~')\ :\ 'none'}\ <F1>:help\ %h%q%w%m%r%=%{&ft}\ %{&fenc}[%{&ff}]%{get(g:,'statusline_full','')}\ %-14.(%l,%c%V%)\ %P
setlocal winfixheight
setlocal winfixwidth
setlocal winfixbuf
# TODO, global
# setlocal noconfirm
setlocal number
setlocal cursorline
setlocal nocursorcolumn
setlocal nowrap
setlocal nospell
setlocal nolist
setlocal noswapfile
setlocal nobuflisted
setlocal buftype=nowrite
setlocal bufhidden=wipe
if get(g:, 'git_no_mappings') == 0
  nnoremap <buffer> <nowait> <silent> <CR> <Plug>(git-do-action)
  nnoremap <buffer> <nowait> <silent> gA <Plug>(git-add-file)
  nnoremap <buffer> <nowait> <silent> gb <Plug>(git-blame)
  nnoremap <buffer> <nowait> <silent> gB <Plug>(git-blame-short)
  nnoremap <buffer> <nowait> <silent> gC <Plug>(git-checkout-file)
  nnoremap <buffer> <nowait> <silent> gd <Plug>(git-diff-file)
  nnoremap <buffer> <nowait> <silent> gh <Plug>(git-help)
  nnoremap <buffer> <nowait> <silent> H <Plug>(git-help)
  nnoremap <buffer> <nowait> <silent> <F1> <Plug>(git-help)
  nnoremap <buffer> <nowait> <silent> gl <Plug>(git-log-file)
  nnoremap <buffer> <nowait> <silent> gL <Plug>(git-log-one-file)
  nnoremap <buffer> <nowait> <silent> gR <Plug>(git-restore-staged-file)
  nnoremap <buffer> <nowait> <silent> gs <Plug>(git-status-file)
  nnoremap <buffer> <nowait> <silent> gS <Plug>(git-show-file)
endif

# undo
b:undo_ftplugin = 'setlocal syntax< statusline< winfixheight< winfixwidth< winfixbuf< number< cursorline< cursorcolumn< wrap< spell< list< swapfile< buflisted< buftype< bufhidden<'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <CR>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gA'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gb'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gB'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gC'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gd'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gh'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> H'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <F1>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gl'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gL'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gR'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gs'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> gS'
