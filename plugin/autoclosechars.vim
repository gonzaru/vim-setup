" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_autoeclosechars') == 1 || !get(g:, 'autoclosechars_enabled') || &cp
  finish
endif
let g:loaded_autoclosechars = 1

" mappings
nnoremap <silent> <unique> <script> <Plug>(autoclosechars-toggle) :<C-u>call autoclosechars#Toggle()<CR>
inoremap <silent> <unique> <script> <Plug>(autoclosechars-braceleft) <C-r>=autoclosechars#Close("braceleft", getchar())<CR>
inoremap <silent> <unique> <script> <Plug>(autoclosechars-parenleft) <C-r>=autoclosechars#Close("parenleft", getchar())<CR>
inoremap <silent> <unique> <script> <Plug>(autoclosechars-bracketleft) <C-r>=autoclosechars#Close("bracketleft", getchar())<CR>
