" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_runprg') == 1 || !get(g:, 'runprg_enabled') || &cp
  finish
endif
let g:loaded_runprg = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(runprg-laststatus) :<C-u>call runprg#Run()<CR>
nnoremap <silent> <unique> <script> <Plug>(runprg-window) :<C-u>call runprg#RunWindow()<CR>
