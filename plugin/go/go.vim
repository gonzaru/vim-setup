" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" go basic syntax check
" go vet syntax check

" do not read the file if is already loaded
if exists('g:loaded_go') && g:loaded_go == 1
  finish
endif
let g:loaded_go = 1

" user tmp dir
let s:tmp = UserTempDir()

" go check
let s:go_filebuff = s:tmp."/".$USER."-vimbuff_go_syntax.txt"
let s:go_filesyntax = s:tmp."/".$USER."-vimerr_go_syntax.txt"

" go vet
let s:go_vetfilebuff = s:tmp."/".$USER."-vimbuff_go_vetsyntax.txt"
let s:go_vetfilesyntax = s:tmp."/".$USER."-vimerr_go_vetsyntax.txt"

" checks if buffer is empty
function! s:GOBufferIsEmpty() abort
  return (line('$') == 1 && getline(1) == '') ? 1 : 0
endfunction

" for statusline
function! g:GOStatusLine() abort
  if exists("s:go_error") && s:go_error
    let l:output = "[GO=".s:go_error."]{GV}"
  elseif exists("s:gv_error") && s:gv_error
    let l:output = "[GO][GV=".s:gv_error."]"
  else
    let l:output = "[GO][GV]"
  endif
  return l:output
endfunction

" go check
function! g:GOCheck(mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  " let l:curline = line('.')
  let s:go_error = 0
  if s:GOBufferIsEmpty()
    return
  endif
  if &filetype !=# "go"
    throw "Error: (GOCheck) " . l:curbufname . " is not a valid go file!"
  endif
  if !executable("gofmt")
    throw "Error: (GOCheck) program gofmt is missing!"
  endif
  " sign_unplace() does not support 'name' : 'error_name'
  " call sign_unplace('', {'buffer' : l:curbufnr, 'id' : l:curline})
  call RemoveSignsName(l:curbufnr, "go_error")
  call RemoveSignsName(l:curbufnr, "go_veterror")
  if a:mode ==# "read"
    let l:check_file = l:curbufname
  elseif a:mode ==# "write"
    silent execute "write! " . s:go_filebuff
    let l:check_file = s:go_filebuff
  endif
  " send to stderr, goftm puts all output file in stdout
  call system("gofmt -e " . l:check_file . " 2>  " . s:go_filesyntax)
  if v:shell_error != 0
    let s:go_error = 1
    let l:errout = trim(system("cut -d ':' -f2- " . s:go_filesyntax . " | head -n1"))
    let l:errline = split(l:errout, ":")[0]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'go_error', l:curbufnr, {'lnum' : l:errline})
      call cursor(l:errline, 1)
    endif
    if a:mode ==# "write" && filereadable(s:go_filebuff)
      call delete(s:go_filebuff)
    endif
    throw "Error: (".a:mode.") " . l:errout
  endif
  if a:mode ==# "write" && filereadable(s:go_filebuff)
    call delete(s:go_filebuff)
  endif
endfunction

" go vet (no exec)
function! s:GOVetNoExec() abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  let s:gv_error = 0
  if &filetype !=# "go"
    throw "Error: (GOVetNoExec) " . l:curbufname . " is not a valid go file!"
  endif
  if !filereadable(s:go_vetfilesyntax)
    throw "Error: (GOVetNoExec) ". s:go_vetfilesyntax . " is not readable!"
  endif
  call RemoveSignsName(l:curbufnr, "go_veterror")
  let l:errout = trim(system("grep '^vet: ' " . s:go_vetfilesyntax . " | cut -d ':' -f3- | head -n1"))
  " some errors are with ^filename (not ^vet)
  if empty(l:errout)
    let l:errout = trim(system("grep ^" . l:curbufname . ":" . " " . s:go_vetfilesyntax . " | cut -d ':' -f2- | head -n1"))
  endif
  if !empty(l:errout)
    let s:gv_error = 1
    let l:errline = split(l:errout, ":")[0]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'go_veterror', l:curbufnr, {'lnum' : l:errline})
    endif
  endif
endfunction

" go vet async
function! g:GOVetAsync() abort
  " depends on GoCheck()
   if exists("s:go_error") && s:go_error
     echohl ErrorMsg
     echom "Error: (GOCheck) previous function contains errors"
     echom "Error: (GOVetAsync) detected error"
     echohl None
     return
  endif
  if !s:GOBufferIsEmpty() && &filetype ==# "go"
    let l:job = job_start("go vet " . bufname('%'), {"out_cb": "OutHandlerGOVet", "err_cb": "ErrHandlerGOVet", "exit_cb": "s:ExitHandlerGOVet", "out_io": "file", "out_name": s:go_vetfilesyntax, "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! s:OutHandlerGOVet(channel, message) abort
endfunction

function! s:ErrHandlerGOVet(channel, message) abort
endfunction

function! s:ExitHandlerGOVet(job, status) abort
  call s:GOVetNoExec()
  " TODO: recheck if necessary
  redraw!
endfunction

" shows debug information
function! g:ShowGODebugInfo(signame) abort
  if a:signame ==# "go_error"
    call s:GOShowErrorPopup()
  elseif a:signame ==# "go_veterror"
    call s:GOVetShowErrorPopup()
  else
    throw "Error: unknown sign " . a:signame
  endif
endfunction

" shows go check error popup
function! s:GOShowErrorPopup() abort
  let l:curline = line('.')
  let l:errmsg = systemlist("grep -F :". l:curline . ":" . " " . s:go_filesyntax . " | cut -d ':' -f2-")
  echo "GO: " .join(l:errmsg)
  call popup_create("GO: " . join(l:errmsg), #{
  \ pos: 'topleft',
  \ line: 'cursor-3',
  \ col: winwidth(0)/4,
  \ moved: 'any',
  \ border: [],
  \ close: 'click'
  \ })
endfunction

" shows go vet error popup
function! s:GOVetShowErrorPopup() abort
  let l:curline = line('.')
  let l:errmsg = systemlist("grep -F :". l:curline . ":" . " " . s:go_vetfilesyntax)
  echo "GV: " .join(l:errmsg)
  call popup_create("GV: " . join(l:errmsg), #{
  \ pos: 'topleft',
  \ line: 'cursor-3',
  \ col: winwidth(0)/4,
  \ moved: 'any',
  \ border: [],
  \ close: 'click'
  \ })
endfunction
