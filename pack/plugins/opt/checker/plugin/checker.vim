" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded or checker is not enabled
if exists('g:loaded_checker') || !get(g:, 'checker_enabled') || &cp
  finish
endif
let g:loaded_checker = 1

" TODO:
" set mappings
" define mappings
" if get(g:, 'checker_no_mappings') == 0
" endif
