vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_cb") || !get(g:, "cyclebuffers_enabled")
  finish
endif
b:did_ftplugin_cb = true

# cb (cycle buffers)
setlocal statusline=%{getline('.')}\ [%{cyclebuffers#GetBufferNum(line('.'))}]\ <F1>:help%=%{line('$')}\ [CB]
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
  nnoremap <buffer> <nowait> <Space> <Plug>(cyclebuffers-select-pedit)
  nnoremap <buffer> <nowait> d <plug>(cyclebuffers-select-delete)
  nnoremap <buffer> <nowait> D <plug>(cyclebuffers-select-delete-keep)
  nnoremap <buffer> <nowait> w <plug>(cyclebuffers-select-wipe)
  nnoremap <buffer> <nowait> W <plug>(cyclebuffers-select-wipe-keep)
  nnoremap <buffer> <nowait> e <plug>(cyclebuffers-select-edit)
  nnoremap <buffer> <nowait> s <Plug>(cyclebuffers-select-split)
  nnoremap <buffer> <nowait> v <Plug>(cyclebuffers-select-vsplit)
  nnoremap <buffer> <nowait> t <Plug>(cyclebuffers-select-tabedit)
  nnoremap <buffer> <nowait> p <Plug>(cyclebuffers-select-pedit)
  nnoremap <buffer> <nowait> P <Plug>(cyclebuffers-close-pedit)
  nnoremap <buffer> <nowait> J j<Plug>(cyclebuffers-select-pedit)
  nnoremap <buffer> <nowait> K k<Plug>(cyclebuffers-select-pedit)
  nnoremap <buffer> <nowait> H <Plug>(cyclebuffers-help)
  nnoremap <buffer> <nowait> <F1> <Plug>(cyclebuffers-help)
endif

# undo
b:undo_ftplugin = 'setlocal statusline< winfixbuf< signcolumn< number< cursorline< cursorcolumn< wrap< spell< list< swapfile< buflisted< modifiable< buftype< bufhidden<'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <Esc>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <CR>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <Space>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> d'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> D'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> w'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> W'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> e'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> s'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> v'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> t'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> p'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> P'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> J'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> K'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> H'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <F1>'
