" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Se simple explorer

" See also ../../ftplugin/se.vim

" do not read the file if it is already loaded or se is not enabled
if get(g:, 'loaded_se') == 1 || get(g:, 'se_enabled') == 0 || &cp
  finish
endif
let g:loaded_se = 1

" define mappings
nnoremap <silent> <unique> <script> <Plug>(se-toggle) :<C-u>call se#Toggle()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-refreshlist) :<C-u>call se#RefreshList()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-followfile) :<C-u>call se#FollowFile()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-edit) :<C-u>call se#Gofile("edit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-editk) :<C-u>call se#Gofile("editk")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-pedit) :<C-u>call se#Gofile("pedit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-split) :<C-u>call se#Gofile("split")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-vsplit) :<C-u>call se#Gofile("vsplit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-tabedit) :<C-u>call se#Gofile("tabedit")<CR>

" see ../ftplugin/se.vim
" set mappings
if get(g:, 'se_no_mappings') == 0
  nnoremap <leader>se <Plug>(se-toggle)
  command! SeToggle :call se#Toggle()
endif
