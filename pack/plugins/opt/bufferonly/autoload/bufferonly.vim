" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:autoloaded_bufferonly') || !get(g:, 'bufferonly_enabled') || &cp
  finish
endif
let g:autoloaded_bufferonly = 1

" remove all buffers except the current one
function! bufferonly#RemoveAllExceptCurrent(mode)
  let l:curbufid = winbufnr(winnr())
  if a:mode ==# 'delete' || a:mode ==# 'wipe'
    let l:bufinfo = getbufinfo({'buflisted':1})
  elseif a:mode ==# 'wipe!'
    let l:bufinfo = getbufinfo()
  endif
  for l:b in l:bufinfo
    if l:b.bufnr == l:curbufid
      continue
    endif
    if getbufvar(l:b.bufnr, '&buftype') ==# 'terminal' && term_getstatus(l:b.bufnr) ==# 'running,normal'
      if a:mode ==# "delete"
        execute "bd! " . l:b.bufnr
      elseif a:mode ==# "wipe" || a:mode ==# "wipe!"
        execute "bw! " . l:b.bufnr
      endif
    else
      if a:mode ==# "delete"
        execute "bd " . l:b.bufnr
      elseif a:mode ==# "wipe" || a:mode ==# "wipe!"
        execute "bw " . l:b.bufnr
      endif
    endif
  endfor
endfunction
