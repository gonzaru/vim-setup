" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_cyclebuffers') == 1 || !get(g:, 'cyclebuffers_enabled') || &cp
  finish
endif
let g:loaded_cyclebuffers = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(cyclebuffers) :<C-u>call cyclebuffers#Cycle()<CR>
