" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'autoloaded_autoendstructs') == 1 || !get(g:, 'autoendstructs_enabled') || &cp
  finish
endif
let g:autoloaded_autoendstructs = 1

" automatic end of structures
function! autoendstructs#End()
  if !get(g:, "autoendstructs_enabled") || &filetype !~# 'vim\|sh'
    return "\<CR>"
  endif
  let s:end = {
    \ 'vim': { 'if': 'endif', 'while': 'endwhile', 'for': 'endfor', 'try': 'endtry', 'function': 'endfunction', 'function!': 'endfunction', 'def': 'enddef' },
    \ 'sh': { 'if': 'fi', 'while': 'done', 'for': 'done', 'until': 'done', 'case': 'esac' }
  \ }
  let l:line = getline('.')
  if empty(trim(l:line))
    return "\<CR>"
  endif
  let l:firstword = split(l:line, " ")[0]
  let l:lastword = split(l:line, " ")[-1]
  if &ft ==# 'vim' && l:firstword =~# '^\(if\|while\|for\|try\|function\|case\|def\)$'
    return "\<CR>".s:end['vim'][l:firstword]."\<ESC>O"
  elseif &ft ==# 'sh' && l:firstword =~# '^\(if\|while\|for\|until\|case\)$' && l:lastword =~# '^\(then\|do\|in\)$'
    return "\<CR>".s:end['sh'][l:firstword]."\<ESC>O"
  endif
  return "\<CR>"
endfunction

" toggle automatic end of structures
function! autoendstructs#Toggle()
  let g:autoendstructs_enabled = !get(g:, "autoendstructs_enabled")
  let v:statusmsg = "autoendstructs=" . g:autoendstructs_enabled
endfunction
