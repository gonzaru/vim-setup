" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:autoloaded_scratch') || !get(g:, 'scratch_enabled') || &cp
  finish
endif
let g:autoloaded_scratch = 1

" scratch buffer
function! scratch#Buffer()
  let l:curbufn = winbufnr(winnr())
  let l:scnum = 0
  let l:match = 0
  for l:b in getbufinfo()
    " :help special-buffers
    if empty(l:b.name)
    \ && getbufvar(l:b.bufnr, '&buftype') ==# 'nofile'
    \ && getbufvar(l:b.bufnr, '&bufhidden') ==# 'hide'
    \ && getbufvar(l:b.bufnr, '&swapfile') == 0
    \ && getbufvar(l:b.bufnr, '&buflisted') == 0
      let l:scnum = l:b.bufnr
      let l:match = 1
      break
    endif
  endfor
  if l:match
    if l:curbufn == l:scnum
      " return to previous buffer if we are in the scratch
      if !empty(getreg('#'))
        execute "b #"
      endif
    else
      execute "b " . l:scnum
    endif
  else
    enew
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
  endif
endfunction

" scratch terminal
function! scratch#Terminal()
  let l:curbufn = winbufnr(winnr())
  let l:scnum = 0
  let l:match = 0
  for l:b in getbufinfo()
    if l:b.name =~# "[ScratchTerminal]"
    \ && getbufvar(l:b.bufnr, '&buftype') ==# 'terminal'
    \ && term_getstatus(l:b.bufnr) ==# 'running,normal'
    \ && getbufvar(l:b.bufnr, '&bufhidden') ==# 'hide'
    \ && getbufvar(l:b.bufnr, '&swapfile') == 0
    \ && getbufvar(l:b.bufnr, '&buflisted') == 0
      let l:scnum = l:b.bufnr
      let l:match = 1
      break
    endif
  endfor
  if l:match
    if l:curbufn == l:scnum
      " return to previous buffer if we are in the scratch
      if !empty(getreg('#'))
        execute "b #"
      endif
    else
      execute "b " . l:scnum
    endif
  else
    terminal ++curwin ++noclose ++norestore
    keepalt file [ScratchTerminal]
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
  endif
endfunction
