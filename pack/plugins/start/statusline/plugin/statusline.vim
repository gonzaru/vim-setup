" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'loaded_statusline') == 1 || get(g:, 'statusline_enabled') == 0 || &cp
  finish
endif
let g:loaded_statusline = 1

" see ../autoload/statusline.vim

" TODO:
" set mappings
" define mappings
" if get(g:, 'statusline_no_mappings') == 0
" endif
