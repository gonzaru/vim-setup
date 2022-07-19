" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded or se is not enabled
if exists("b:did_ftplugin_se") || get(g:, "se_enabled") == 0
  finish
endif
let b:did_ftplugin_se = 1

" Se
setlocal statusline=b%n,w%{win_getid()}%h%=[SE]
setlocal winfixheight
setlocal winfixwidth
setlocal noconfirm
setlocal nocursorline
setlocal nocursorcolumn
setlocal nospell
setlocal nolist
setlocal splitright
setlocal noswapfile
setlocal nobuflisted
setlocal buftype=nowrite
setlocal bufhidden=hide
if get(g:, 'se_no_mappings') == 0
  nnoremap <buffer><CR> <Plug>(se-gofile-edit)
  nnoremap <buffer><Space> <Plug>(se-gofile-editk)
  nnoremap <buffer>e <Plug>(se-gofile-edit)
  nnoremap <buffer>E <Plug>(se-gofile-edit)<Plug>(se-toggle)
  nnoremap <buffer>p <Plug>(se-gofile-pedit)
  nnoremap <buffer>P :pclose<CR>
  nnoremap <buffer>s <Plug>(se-gofile-split)
  nnoremap <buffer>S <Plug>(se-gofile-split)<Plug>(se-toggle)
  nnoremap <buffer>v <Plug>(se-gofile-vsplit)
  nnoremap <buffer>V <Plug>(se-gofile-vsplit)<Plug>(se-toggle)
  nnoremap <buffer>t <Plug>(se-gofile-tabedit)
  nnoremap <buffer>- :call cursor(1, 1)<CR><Plug>(se-gofile-edit)
  nnoremap <buffer>r <Plug>(se-refreshlist)
  nnoremap <buffer>f <Plug>(se-followfile)
  nnoremap <buffer><BS> :execute ":vertical resize " . g:se_winsize<CR>
  nnoremap <buffer><C-h> :execute ":vertical resize " . g:se_winsize<CR>
endif
