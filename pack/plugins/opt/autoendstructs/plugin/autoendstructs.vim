" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:loaded_autoendstructs') || !get(g:, 'autoendstructs_enabled') || &cp
  finish
endif
let g:loaded_autoendstructs = 1

" define mappings
nnoremap <silent> <unique> <script> <Plug>(autoendstructs-toggle) :<C-u>call autoendstructs#Toggle()<CR>
inoremap <silent> <unique> <script> <Plug>(autoendstructs-end) <C-r>=autoendstructs#End()<CR>

" set mappings
if get(g:, 'autoendstructs_no_mappings') == 0
  nnoremap <leader>tge <Plug>(autoendstructs-toggle):echo v:statusmsg<CR>
endif
