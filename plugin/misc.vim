" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" g:  global variables
" b:  local buffer variables
" w:  local window variables
" t:  local tab page variables
" s:  script-local variables
" l:  local function variables
" v:  Vim variables.

" do not read the file if it is already loaded
if exists('g:loaded_misc') || !get(g:, 'misc_enabled') || &cp
  finish
endif
let g:loaded_misc = 1

" see ../autoload/misc.vim

" go to last edit cursor position
function! s:GoLastEditCursorPos()
  let l:lastcursorline = line("'\"")
  if l:lastcursorline >= 1 && l:lastcursorline <= line("$") && &ft !~# "commit"
    execute "normal! g`\""
  endif
endfunction

" mappings
nnoremap <silent> <unique> <script> <Plug>(misc-golasteditcursor) :<C-u>call <SID>GoLastEditCursorPos()<CR>
