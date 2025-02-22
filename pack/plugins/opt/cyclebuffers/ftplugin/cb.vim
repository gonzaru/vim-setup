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
setlocal winfixbuf
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
  nnoremap <buffer> <nowait> <ESC> <Plug>(cyclebuffers-close)
  nnoremap <buffer> <nowait> <CR> <Plug>(cyclebuffers-select-edit)
  nnoremap <buffer> <nowait> d <plug>(cyclebuffers-select-delete)
  nnoremap <buffer> <nowait> D <plug>(cyclebuffers-select-delete!)
  nnoremap <buffer> <nowait> w <plug>(cyclebuffers-select-wipe)
  nnoremap <buffer> <nowait> W <plug>(cyclebuffers-select-wipe!)
  nnoremap <buffer> <nowait> e <plug>(cyclebuffers-select-edit)
  nnoremap <buffer> <nowait> s <Plug>(cyclebuffers-select-split)
  nnoremap <buffer> <nowait> v <Plug>(cyclebuffers-select-vsplit)
  nnoremap <buffer> <nowait> t <Plug>(cyclebuffers-select-tabedit)
  nnoremap <buffer> <nowait> H <Plug>(cyclebuffers-help)
  nnoremap <buffer> <nowait> K <Plug>(cyclebuffers-help)
endif
