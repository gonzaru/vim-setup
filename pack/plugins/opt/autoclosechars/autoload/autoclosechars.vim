" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:autoloaded_autoeclosechars') || !get(g:, 'autoclosechars_enabled') || &cp
  finish
endif
let g:autoloaded_autoclosechars = 1

" automatic close of chars [,(,[
function! autoclosechars#Close(mode, nr)
  if !get(g:, "autoclosechars_enabled")
    return nr2char(a:nr)
  endif
  let l:key = {'tab': 9, 'enter': 13, 'quote': 34, 'apostrophe': 39}
  if a:mode ==# "braceleft"
    if a:nr == l:key['enter']
      return "\<CR>}\<ESC>O"
    elseif a:nr == l:key['tab']
      return "}\<left>"
    endif
  endif
  if a:mode ==# "parenleft"
    if a:nr == l:key['enter']
      return "\<CR>)\<ESC>O"
    elseif a:nr == l:key['tab'] || a:nr == l:key['quote']
      return "\"\")\<left>\<left>"
    elseif a:nr == l:key['apostrophe']
      return "'')\<left>\<left>"
    endif
  endif
  if a:mode ==# "bracketleft"
    if a:nr == l:key['enter']
      return "\<CR>]\<ESC>O"
    elseif a:nr == l:key['tab'] || a:nr == l:key['quote']
      return "\"\"]\<left>\<left>"
    elseif a:nr == l:key['apostrophe']
      return "'']\<left>\<left>"
    endif
  endif
  return nr2char(a:nr)
endfunc

" toggle automatic close of chars
function! autoclosechars#Toggle()
  let g:autoclosechars_enabled = !get(g:, "autoclosechars_enabled")
  let v:statusmsg = "autoclosechars=" . g:autoclosechars_enabled
endfunction
