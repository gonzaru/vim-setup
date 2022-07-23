vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if exists("b:did_ftplugin_cb") || !get(g:, "cyclebuffers_enabled") || &cp
  finish
endif
b:did_ftplugin_cb = 1

# cb (cycle buffers)
setlocal statusline=%{getline('.')}\ [%{buffer_number(getline('.'))}]%=%{line('$')}\ [CB]
setlocal signcolumn=no
setlocal number
setlocal cursorline
setlocal nocursorcolumn
setlocal nowrap
setlocal nospell
setlocal nolist
setlocal noswapfile
setlocal nobuflisted
setlocal nomodifiable
setlocal buftype=nowrite
setlocal bufhidden=wipe
if get(g:, 'cyclebuffers_no_mappings') == 0
  if empty(mapcheck("<CR>", "n"))
    nnoremap <buffer><CR> <Plug>(cyclebuffers-select)
  endif
  if empty(mapcheck("<Esc>", "n"))
    nnoremap <buffer><Esc> :close<CR>
  endif
endif
