" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_scratch') == 1 || !get(g:, 'scratch_enabled') || &cp
  finish
endif
let g:loaded_scratch = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(scratch-buffer) :<C-u>call scratch#Buffer()<CR>
nnoremap <silent> <unique> <script> <Plug>(scratch-terminal) :<C-u>call scratch#Terminal()<CR>
