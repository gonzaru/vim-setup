" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded or checker is not enabled
if get(g:, 'loaded_checker') == 1 || get(g:, 'checker_enabled') == 0 || &cp
  finish
endif
let g:loaded_checker = 1

" TODO:
" mappings
