" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_bufferonly') == 1 || !get(g:, 'bufferonly_enabled') || &cp
  finish
endif
let g:loaded_bufferonly = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(bufferonly-delete) :<C-u>call bufferonly#RemoveAllExceptCurrent("delete")<CR>
nnoremap <silent> <unique> <script> <Plug>(bufferonly-wipe) :<C-u>call bufferonly#RemoveAllExceptCurrent("wipe")<CR>
nnoremap <silent> <unique> <script> <Plug>(bufferonly-wipe!) :<C-u>call bufferonly#RemoveAllExceptCurrent("wipe!")<CR>
