vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_cb") || !get(g:, "cyclebuffers_enabled")
  finish
endif
b:did_ftplugin_cb = true

# cb (cycle buffers)
setlocal statusline=%{getline('.')}\ [%{cyclebuffers#GetBufferNum(line('.'))}]%=%{line('$')}\ [CB]
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
  nnoremap <buffer> <nowait> <CR> <Plug>(cyclebuffers-select)
  nnoremap <buffer> <nowait> <ESC> :close<CR>
endif
