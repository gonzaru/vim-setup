" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:autoloaded_runprg') || !get(g:, 'runprg_enabled') || &cp
  finish
endif
let g:autoloaded_runprg = 1

" prints error message and saves the message in the message-history
function! s:EchoErrorMsg(msg)
  if !empty(a:msg)
    echohl ErrorMsg
    echom  a:msg
    echohl None
  endif
endfunction

" prints warning message and saves the message in the message-history
function! s:EchoWarningMsg(msg)
  if !empty(a:msg)
    echohl WarningMsg
    echom  a:msg
    echohl None
  endif
endfunction

" run
function! runprg#Run()
  let l:curbufname = bufname('%')
  let l:curfile = expand('%:p')
  if index(["sh", "python", "go"], &filetype) == -1
    call s:EchoErrorMsg("Error: running filetype '" . &filetype . "' is not supported")
    return
  endif
  if &filetype ==# "sh"
    echo system(s:SHShellType() . " " . l:curfile)
  elseif &filetype ==# "python"
    echo system("python3 " . l:curfile)
  elseif &filetype ==# "go"
    echo system("go run " . l:curfile)
  endif
  if v:shell_error
    call s:EchoErrorMsg("Error: exit code " . v:shell_error)
  endif
endfunction

" run using a window
function! runprg#RunWindow()
  let l:bufoutname = "runoutput"
  let l:curbufname = bufname('%')
  let l:curfile = expand('%:p')
  let l:curwinid = win_getid()
  let l:prevwinid = bufwinid(l:bufoutname)
  if l:curwinid == l:prevwinid
    call s:EchoWarningMsg("Warning: already using the same window " . l:bufoutname)
    return
  endif
  if index(["sh", "python", "go"], &filetype) == -1
    call s:EchoErrorMsg("Error: running filetype '" . &filetype . "' is not supported")
    return
  endif
  if &filetype ==# "sh"
    let l:out = systemlist(s:SHShellType() . " " . l:curfile)
  elseif &filetype ==# "python"
    let l:out = systemlist("python3 " . l:curfile)
  elseif &filetype ==# "go"
    let l:out = systemlist("go run " . l:curfile)
  endif
  if v:shell_error
    call s:EchoErrorMsg("Error: exit code " . v:shell_error)
  endif
  if empty(l:out)
    call s:EchoWarningMsg("Warning: empty output")
    return
  endif
  if l:prevwinid > 0
    call win_gotoid(l:prevwinid)
  else
    if !empty(bufname(l:bufoutname))
      silent execute "bw! " . l:bufoutname
    endif
    below new
    setlocal winfixheight
    setlocal winfixwidth
    setlocal buftype=nowrite
    setlocal noswapfile
    setlocal buflisted
    execute "file " . l:bufoutname
  endif
  call appendbufline('%', 0, l:out)
  call deletebufline('%', '$')
  call cursor(1, 1)
  execute "resize " . len(l:out)
  call win_gotoid(l:curwinid)
endfunction

" detects if the shell is sh or bash using shebang
function! s:SHShellType()
  if &filetype !=# "sh"
    call s:EchoErrorMsg("Error: filetype '" . &filetype . "' is not supported")
    return
  endif
  return getline(1) =~# "bash$" ? "bash" : "sh"
endfunction
