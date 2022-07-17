" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_autoendstructs') == 1 || !get(g:, 'autoendstructs_enabled') || &cp
  finish
endif
let g:loaded_autoendstructs = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(autoendstructs-toggle) :<C-u>call autoendstructs#Toggle()<CR>
inoremap <silent> <unique> <script> <Plug>(autoendstructs-end) <C-r>=autoendstructs#End()<CR>
