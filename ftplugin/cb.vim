" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" cb (cycle buffers)
setlocal statusline=%{getline('.')}\ [%{buffer_number(getline('.'))}]%=%{line('$')}\ [CB]
setlocal signcolumn=no
setlocal number
setlocal cursorline
setlocal nocursorcolumn
setlocal noswapfile
setlocal nobuflisted
setlocal nomodifiable
setlocal buftype=nowrite
setlocal bufhidden=wipe
nnoremap <buffer><CR> :let curbufid = winbufnr(winnr())<CR>
                     \:let prevwinid = bufwinid('#')<CR>
                     \:let line = fnameescape(getline('.'))<CR>
                     \:close<CR>
                     \:call win_gotoid(prevwinid)<CR>
                     \:execute ":e " . line<CR>
nnoremap <buffer><Esc> :close<CR>
