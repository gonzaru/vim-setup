" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_bufferonly') == 1 || !get(g:, 'bufferonly_enabled') || &cp
  finish
endif
let g:loaded_bufferonly = 1

" define mappings
nnoremap <silent> <unique> <script> <Plug>(bufferonly-delete) :<C-u>call bufferonly#RemoveAllExceptCurrent("delete")<CR>
nnoremap <silent> <unique> <script> <Plug>(bufferonly-wipe) :<C-u>call bufferonly#RemoveAllExceptCurrent("wipe")<CR>
nnoremap <silent> <unique> <script> <Plug>(bufferonly-wipe!) :<C-u>call bufferonly#RemoveAllExceptCurrent("wipe!")<CR>

" set mappings
if get(g:, 'bufferonly_no_mappings') == 0
  nnoremap <leader>bo <Plug>(bufferonly-delete)
  nnoremap <leader>bO <Plug>(bufferonly-wipe)
  command! BufferOnlyDelete :call bufferonly#RemoveAllExceptCurrent("delete")
  command! BufferOnlyWipe :call bufferonly#RemoveAllExceptCurrent("wipe")
  command! -bang BufferOnlyWipe :call bufferonly#RemoveAllExceptCurrent("wipe!")
endif
