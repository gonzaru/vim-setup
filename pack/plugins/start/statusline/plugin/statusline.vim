" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:loaded_statusline') || !get(g:, 'statusline_enabled') || &cp
  finish
endif
let g:loaded_statusline = 1

" see ../autoload/statusline.vim

" TODO:
" set mappings
" define mappings
" if get(g:, 'statusline_no_mappings') == 0
" endif
