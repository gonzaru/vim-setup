" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" go basic syntax check
" go vet syntax check

" do not read the file if is already loaded
if exists('g:loaded_go') && g:loaded_go == 1
  finish
endif
let g:loaded_go = 1
let g:loaded_py3_go = 0

" GOCheck
let s:go_filebuff = "/tmp/".$USER."-vimbuff_go_syntax.txt"
let s:go_filesyntax = "/tmp/".$USER."-vimerr_go_syntax.txt"

" GOVet
let s:go_vetfilebuff = "/tmp/".$USER."-vimbuff_go_vetsyntax.txt"
let s:go_vetfilesyntax = "/tmp/".$USER."-vimerr_go_vetsyntax.txt"

" cleanup
function! s:cleanup(mode)
  if a:mode ==# "write" && filereadable(s:go_filebuff)
    call delete(s:go_filebuff)
  endif
endfunction

" buffer is empty
function! s:GOBufferIsEmpty()
  return (line('$') == 1 && getline(1) == '') ? 1 : 0
endfunction

" loads go.py
function! s:GOInit()
  if !exists('g:loaded_py3_go') || (exists('g:loaded_py3_go') && g:loaded_py3_go == 0)
    py3file $HOME/.vim/plugin/go/go.py
  endif
  let g:loaded_py3_go = 1
endfunction

" statusline
function! GOStatusLine()
  if exists("s:go_error") && s:go_error
    let l:output = "[GO=".s:go_error."][GV]"
  elseif exists("s:gv_error") && s:gv_error
    let l:output = "[GV][GV=".s:gv_error."]"
  else
    let l:output = "[GO][GV]"
  endif
  return l:output
endfunction

" check
function! GOCheck(mode)
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
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

  call RemoveSignsName(l:curbufnr, "go_error")
  if a:mode ==# "read"
    let l:check_file = l:curbufname
  elseif a:mode ==# "write"
    silent execute "write! " . s:go_filebuff
    let l:check_file = s:go_filebuff
  endif
  " send only stderr, because goftm puts all output file in stdout
  call system("gofmt -e " . l:check_file . " 2>  " . s:go_filesyntax)
  if v:shell_error != 0
    let s:go_error = 1
    let l:errout = trim(system("cut -d ':' -f2- " . s:go_filesyntax . " | head -n1"))
    let l:errline = trim(system("cut -d ':' -f2 " . s:go_filesyntax . " | head -n1"))
    execute ":sign place ".l:errline." line=".l:errline." name=go_error buffer=".l:curbufnr
    call cursor(l:errline, 1)
    call s:cleanup(a:mode)
    throw "Error: (".a:mode.") " . l:errout
  endif
  call s:cleanup(a:mode)
endfunction

function! s:GOVetNoExec()
  call s:GOInit()
  py3 go_vet_noexec()
endfunction

function! GOVetAsync()
  " depends on GoCheck()
   if exists("s:go_error") && s:go_error
     echohl ErrorMsg
     echom "Error: (GOCheck) previous function contains errors"
     echom "Error: (GOVetAsync) detected error"
     echohl None
     return
  endif
  if !s:GOBufferIsEmpty() && &filetype ==# "go"
    let l:job = job_start("go vet " . bufname('%'), {"out_cb": "OutHandlerGOVet", "err_cb": "ErrHandlerGOVet", "exit_cb": "ExitHandlerGOVet", "out_io": "file", "out_name": s:go_vetfilesyntax, "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! OutHandlerGOVet(channel, message)
endfunction

function! ErrHandlerGOVet(channel, message)
endfunction

function! ExitHandlerGOVet(job, status)
  call s:GOVetNoExec()
endfunction

" shows debug information
function! ShowGODebugInfo()
  let l:curbufnr = winbufnr(winnr())
  let l:curline = line('.')

  redir => signsbuf
  silent execute ":sign place buffer=" . l:curbufnr
  redir END
  if !empty(signsbuf)
    for sb in split(signsbuf, "\n")
      if sb =~# "line=".l:curline." "
        if sb =~# "name=go_error "
          call s:GOShowErrorPopup()
          break
        elseif sb =~# "name=go_veterror "
          call s:GOVetShowErrorPopup()
          break
        else
          throw "Error: unknown sign " . sb
        endif
      endif
    endfor
  endif
endfunction

" shows GO error popup
function! s:GOShowErrorPopup()
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

" shows GOVet error popup
function! s:GOVetShowErrorPopup()
  let l:curline = line('.')
  let l:errmsg = systemlist("grep -F :". l:curline . ":" . " " . s:go_vetfilesyntax . " | cut -d ':' -f3-")
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
