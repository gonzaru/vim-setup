" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'autoloaded_arrowkeys') == 1 || !get(g:, 'arrowkeys_enabled') || &cp
  finish
endif
let g:autoloaded_arrowkeys = 1

" enable arrow keys
function! arrowkeys#Enable()
  silent execute "nnoremap <up> <up>"
  silent execute "nnoremap <down> <down>"
  silent execute "nnoremap <left> <left>"
  silent execute "nnoremap <right> <right>"
  silent execute "inoremap <up> <up>"
  silent execute "inoremap <down> <down>"
  silent execute "inoremap <left> <left>"
  silent execute "inoremap <right> <right>"
  silent execute "vnoremap <up> <up>"
  silent execute "vnoremap <down> <down>"
  silent execute "vnoremap <left> <left>"
  silent execute "vnoremap <right> <right>"
endfunction

" disable arrow keys
function! arrowkeys#Disable()
  silent execute "nnoremap <up> <nop>"
  silent execute "nnoremap <down> <nop>"
  silent execute "nnoremap <left> <nop>"
  silent execute "nnoremap <right> <nop>"
  silent execute "inoremap <up> <nop>"
  silent execute "inoremap <down> <nop>"
  silent execute "inoremap <left> <nop>"
  silent execute "inoremap <right> <nop>"
  silent execute "vnoremap <up> <nop>"
  silent execute "vnoremap <down> <nop>"
  silent execute "vnoremap <left> <nop>"
  silent execute "vnoremap <right> <nop>"
endfunction
