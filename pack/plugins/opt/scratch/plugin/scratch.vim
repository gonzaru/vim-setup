" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_scratch') == 1 || !get(g:, 'scratch_enabled') || &cp
  finish
endif
let g:loaded_scratch = 1

" define mappings
nnoremap <silent> <unique> <script> <Plug>(scratch-buffer) :<C-u>call scratch#Buffer()<CR>
nnoremap <silent> <unique> <script> <Plug>(scratch-terminal) :<C-u>call scratch#Terminal()<CR>

" set mappings
if get(g:, 'scratch_no_mappings') == 0
  nnoremap <silent><leader>s<BS> <Plug>(scratch-buffer)
  nnoremap <silent><leader>s<CR> <Plug>(scratch-terminal)
  nnoremap <silent><leader>sc <Plug>(scratch-buffer)
  nnoremap <silent><leader>sz <Plug>(scratch-terminal)
  command! ScratchBuffer :call scratch#Buffer()
  command! ScratchTerminal :call scratch#Terminal()
endif
