" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_runprg') == 1 || !get(g:, 'runprg_enabled') || &cp
  finish
endif
let g:loaded_runprg = 1

" define mappings
nnoremap <silent> <unique> <script> <Plug>(runprg-laststatus) :<C-u>call runprg#Run()<CR>
nnoremap <silent> <unique> <script> <Plug>(runprg-window) :<C-u>call runprg#RunWindow()<CR>

" set mappings
if get(g:, 'runprg_no_mappings') == 0
  nnoremap <leader>ru <Plug>(runprg-laststatus)
  nnoremap <leader>rU <Plug>(runprg-window)
  command! Run :call runprg#Run()
  command! RunWindow :call runprg#RunWindow()
endif
