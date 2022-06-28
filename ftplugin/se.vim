" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded or se is not enabled
if exists("b:did_ftplugin") || get(g:, "se_enabled") == 0
  finish
endif
let b:did_ftplugin = 1

" Se
setlocal statusline=b%n,w%{win_getid()}%h%=[SE]
setlocal winfixheight
setlocal winfixwidth
setlocal noconfirm
setlocal nocursorline
setlocal nocursorcolumn
setlocal splitright
setlocal noswapfile
setlocal nobuflisted
setlocal buftype=nowrite
setlocal bufhidden=hide
nnoremap <buffer><CR> :call SeGofile('edit')<CR>
nnoremap <buffer><Space> :call SeGofile('editk')<CR>
nnoremap <buffer>e :call SeGofile('edit')<CR>
nnoremap <buffer>E :call SeGofile('edit')<CR>:call SeToggle()<CR>
nnoremap <buffer>p :call SeGofile('pedit')<CR>
nnoremap <buffer>P :pclose<CR>
nnoremap <buffer>s :call SeGofile('split')<CR>
nnoremap <buffer>S :call SeGofile('split')<CR>:call SeToggle()<CR>
nnoremap <buffer>v :call SeGofile('vsplit')<CR>
nnoremap <buffer>V :call SeGofile('vsplit')<CR>:call SeToggle()<CR>
nnoremap <buffer>t :call SeGofile('tabedit')<CR>
nnoremap <buffer>- :call cursor(1, 1)<CR>:call SeGofile('edit')<CR>
nnoremap <buffer>r :call SeRefreshList()<CR>
nnoremap <buffer>f :call SeFollowFile()<CR>
nnoremap <buffer><BS> :execute ":vertical resize " . g:se_winsize<CR>
nnoremap <buffer><C-h> :execute ":vertical resize " . g:se_winsize<CR>
