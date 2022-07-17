" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_arrowkeys') == 1 || !get(g:, 'arrowkeys_enabled') || &cp
  finish
endif
let g:loaded_arrowkeys = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(arrowkeys-enable) :<C-u>call arrowkeys#Enable()<CR>
nnoremap <silent> <unique> <script> <Plug>(arrowkeys-disable) :<C-u>call arrowkeys#Disable()<CR>
