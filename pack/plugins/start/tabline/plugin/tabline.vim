" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:loaded_tabline') || !get(g:, 'tabline_enabled') || &cp
  finish
endif
let g:loaded_tabline = 1

" see ../autoload/tabline.vim

" TODO:
" set mappings
" define mappings
" if get(g:, 'tabline_no_mappings') == 0
" endif
