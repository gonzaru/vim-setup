vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_git") || !get(g:, "git_enabled")
  finish
endif
b:did_ftplugin_git = true

# Git
setlocal statusline=[git]:%<%{git#GetGitPrevFile()->fnamemodify(':~')}\ %h%q%w%m%r%=%{&ft}\ %{&fenc}[%{&ff}]%{get(g:,'statusline_full','')}\ %-15.(%l,%c%V%)\ %P
setlocal winfixheight
setlocal winfixwidth
setlocal noconfirm
setlocal cursorline
setlocal nocursorcolumn
setlocal nowrap
setlocal nospell
setlocal nolist
setlocal buftype=nowrite
setlocal noswapfile
setlocal buflisted
setlocal syntax=on
if get(g:, 'git_no_mappings') == 0
  if empty(mapcheck("<CR>", "n"))
    nnoremap <silent><buffer><CR> <Plug>(git-show-commit)
  endif
  if empty(mapcheck("<ESC>", "n"))
    nnoremap <silent><buffer><ESC> <Plug>(git-close)
  endif
  if empty(mapcheck("gb", "n"))
    nnoremap <silent><buffer>gb <Plug>(git-blame)
  endif
  if empty(mapcheck("gB", "n"))
    nnoremap <silent><buffer>gB <Plug>(git-blame-short)
  endif
  if empty(mapcheck("gd", "n"))
    nnoremap <silent><buffer>gd <Plug>(git-diff-file)
  endif
  if empty(mapcheck("gh", "n"))
    nnoremap <silent><buffer>gh <Plug>(git-help)
  endif
  if empty(mapcheck("H", "n"))
    nnoremap <silent><buffer>H <Plug>(git-help)
  endif
  if empty(mapcheck("gl", "n"))
    nnoremap <silent><buffer>gl <Plug>(git-log-file)
  endif
  if empty(mapcheck("gL", "n"))
    nnoremap <silent><buffer>gL <Plug>(git-log-one-file)
  endif
  if empty(mapcheck("gs", "n"))
    nnoremap <silent><buffer>gs <Plug>(git-show-file)
  endif
  if empty(mapcheck("gS", "n"))
    nnoremap <silent><buffer>gS <Plug>(git-status-file)
  endif
endif
