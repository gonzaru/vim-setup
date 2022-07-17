" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Se simple explorer

" See also ../../ftplugin/se.vim

" do not read the file if it is already loaded or se is not enabled
if get(g:, 'loaded_se') == 1 || get(g:, 'se_enabled') == 0 || &cp
  finish
endif
let g:loaded_se = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(se-toggle) :<C-u>call se#SeToggle()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-refreshlist) :<C-u>call se#SeRefreshList()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-followfile) :<C-u>call se#SeFollowFile()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-edit) :<C-u>call se#SeGofile("edit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-editk) :<C-u>call se#SeGofile("editk")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-pedit) :<C-u>call se#SeGofile("pedit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-split) :<C-u>call se#SeGofile("split")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-vsplit) :<C-u>call se#SeGofile("vsplit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-tabedit) :<C-u>call se#SeGofile("tabedit")<CR>
