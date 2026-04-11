vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_calculator") || !get(g:, "calculator_enabled")
  finish
endif
b:did_ftplugin_calculator = true

# calculator
setlocal statusline=\ %=%#StatusLine#
setlocal signcolumn=no
setlocal nonumber
setlocal norelativenumber
setlocal nocursorline
setlocal nocursorcolumn
setlocal nowrap
setlocal nospell
setlocal nolist
setlocal winfixbuf
setlocal winfixheight
setlocal winfixwidth
setlocal noswapfile
setlocal nobuflisted
setlocal modifiable
setlocal buftype=nofile
setlocal bufhidden=wipe
if !get(g:, 'calculator_no_mappings')
  nnoremap <buffer> <nowait> q <Plug>(calculator-close)
  inoremap <buffer> <nowait> Q <C-o><Plug>(calculator-close)
  nnoremap <buffer> <nowait> <CR> <Plug>(calculator-evaluate)
  inoremap <buffer> <nowait> <CR> <C-o><Plug>(calculator-evaluate)
endif

# undo
b:undo_ftplugin = 'setlocal statusline< winfixbuf< signcolumn< number< relativenumber< cursorline< cursorcolumn< wrap< spell< list< winfixheight< winfixwidth< swapfile< buflisted< modifiable< buftype< bufhidden<'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> q'
b:undo_ftplugin ..= ' | silent! iunmap <buffer> Q'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <CR>'
b:undo_ftplugin ..= ' | silent! iunmap <buffer> <CR>'
