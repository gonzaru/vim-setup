" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_commentarium') == 1 || !get(g:, 'commentarium_enabled') || &cp
  finish
endif
let g:loaded_commentarium = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(commentarium-do) :<C-u>call commentarium#DoComment()<CR>
nnoremap <silent> <unique> <script> <Plug>(commentarium-undo) :<C-u>call commentarium#UndoComment()<CR>
