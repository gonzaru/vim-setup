" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'autoloaded_cyclebuffers') == 1 || !get(g:, 'cyclebuffers_enabled') || &cp
  finish
endif
let g:autoloaded_cyclebuffers = 1

" prints warning message and saves the message in the message-history
function! s:EchoWarningMsg(msg)
  if !empty(a:msg)
    echohl WarningMsg
    echom  a:msg
    echohl None
  endif
endfunction

" cycle between buffers
function! cyclebuffers#Cycle()
  let l:curbuf = substitute(bufname("%"), $HOME . "/" . $USER . "/", "~/", "")
  let l:bufinfo = getbufinfo({'buflisted':1})
  if len(l:bufinfo) == 1
    call s:EchoWarningMsg("Warning: already using only one buffer")
    return
  endif
  let l:buflist = []
  for l:buf in l:bufinfo
    let l:bul = split(substitute(l:buf.name, $HOME . "/" . $USER . "/", "~/", ""))
    call extend(l:buflist, l:bul)
  endfor
  topleft new
  call appendbufline('%', 0, l:buflist)
  call deletebufline('%', '$')
  execute "resize " . line('$')
  setlocal filetype=cb
  for l:i in range(1, line('$'))
    if l:curbuf ==# getline(l:i)
      call cursor(l:i, 1)
      break
    endif
  endfor
endfunction
