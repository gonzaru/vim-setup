" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if is already loaded
if exists('g:loaded_py3') && g:loaded_py3 == 1
  finish
endif
let g:loaded_py3 = 1

" user tmp dir
let s:tmp = UserTempDir()

" py3 check
let s:py3_filebuff = s:tmp."/".$USER."-vimbuff_py_syntax.txt"
let s:py3_filesyntax = s:tmp."/".$USER."-vimerr_py_syntax.txt"

" py3 pep8
let s:py3_pep8filebuff = s:tmp."/".$USER."-vimbuff_py_pep8syntax.txt"
let s:py3_pep8filesyntax = s:tmp."/".$USER."-vimerr_py_pep8syntax.txt"

" checks if buffer is empty
function! s:PY3BufferIsEmpty() abort
  return (line('$') == 1 && getline(1) == '') ? 1 : 0
endfunction

" for statusline
function! g:PY3StatusLine() abort
  if exists("s:py_error") && s:py_error
    let l:output = "[PY=".s:py_error."]{P8}"
  elseif exists("s:pep8_error") && s:pep8_error
    let l:output = "[PY][P8=".s:pep8_error."]"
  else
    let l:output = "[PY][P8]"
  endif
  return l:output
endfunction

" py3 check
function! g:PY3Check(mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  let s:py_error = 0
  if s:PY3BufferIsEmpty()
    return
  endif
  if &filetype !=# "python"
    throw "error: (PY3check) " . l:curbufname . " is not a valid python file!"
  endif
  call RemoveSignsName(l:curbufnr, "py_error")
  call RemoveSignsName(l:curbufnr, "py_pep8error")
  if a:mode ==# "read"
    let l:check_file = l:curbufname
  elseif a:mode ==# "write"
    silent execute "write! " . s:py3_filebuff
    let l:check_file = s:py3_filebuff
  endif
  call system("python3 -c \"import ast; ast.parse(open('". l:check_file ."').read())\" > " . s:py3_filesyntax . " 2>&1")
  if v:shell_error != 0
    let s:py_error = 1
    let l:errout = readfile(s:py3_filesyntax)
    let l:errline = split(l:errout[4], ", line ")[1]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'py_error', l:curbufnr, {'lnum' : l:errline})
      call cursor(l:errline, 1)
    endif
    if a:mode ==# "write" && filereadable(s:py3_filebuff)
      call delete(s:py3_filebuff)
    endif
    throw "Error: (".a:mode.") " . l:errout
  endif
  if a:mode ==# "write" && filereadable(s:py3_filebuff)
    call delete(s:py3_filebuff)
  endif
endfunction

" py3 pep8 (no exec)
function! s:PY3Pep8NoExec() abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  let s:pep8_error = 0
  if &filetype !=# "python"
    throw "Error: (PY3Pep8NoExec) " . l:curbufname . " is not a valid python file!"
  endif
  if !filereadable(s:py3_pep8filesyntax)
    throw "Error: (PY3Pep8NoExec) ". s:py3_pep8filesyntax . " is not readable!"
  endif
  call RemoveSignsName(l:curbufnr, "py_pep8error")
  let l:terrors = 0
  for l:line in readfile(s:py3_pep8filesyntax)
    let l:errline = split(l:line, ":")[1]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'py_pep8error', l:curbufnr, {'lnum' : l:errline})
    endif
    let l:terrors += 1
  endfor
  if l:terrors
    let s:pep8_error = l:terrors
  endif
endfunction

" py3 pep8 async
function! g:PY3Pep8Async() abort
   " depends on PY3Check()
  if exists("s:py_error") && s:py_error
    echohl ErrorMsg
    echom "Error: (PY3Check) previous function contains errors"
    echom "Error: (PY3Pep8Async) detected error"
    echohl None
    return
  endif
  if !s:PY3BufferIsEmpty() && &filetype ==# "python"
    let l:job = job_start("pep8 " . bufname('%'), {"out_cb": "OutHandlerPY3Pep8", "err_cb": "ErrHandlerPY3Pep8", "exit_cb": "s:ExitHandlerPY3Pep8", "out_io": "file", "out_name": s:py3_pep8filesyntax, "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! s:OutHandlerPY3Pep8(channel, message) abort
endfunction

function! s:ErrHandlerPY3Pep8(channel, message) abort
endfunction

function! s:ExitHandlerPY3Pep8(job, status) abort
  call s:PY3Pep8NoExec()
  " TODO: recheck if necessary
  redraw!
endfunction

" shows debug information
function! g:ShowPY3DebugInfo(signame) abort
  if a:signame ==# "py_error"
    call s:PY3ErrorPopup()
  elseif a:signame ==# "py_pep8error"
    call  s:PY3Pep8ErrorPopup()
  else
    throw "Error: unknown sign " . a:signame
  endif
endfunction

" shows py3 error popup
function! s:PY3ErrorPopup() abort
  let l:curline = line('.')
  let l:errmsg = systemlist("cat " . s:py3_filesyntax)
  echo join(l:errmsg)
  call popup_create(l:errmsg, #{
  \ pos: 'topleft',
  \ line: 'cursor-3',
  \ col: winwidth(0)/4,
  \ moved: 'any',
  \ border: [],
  \ close: 'click'
  \ })
endfunction

" shows pep8 error popup
function! s:PY3Pep8ErrorPopup() abort
  let l:curline = line('.')
  let l:errmsg = systemlist("grep -E ':".l:curline.":.*: ' " . s:py3_pep8filesyntax . " | cut -d ' ' -f2-")
  echo "P8: " . join(l:errmsg)
  call popup_create("P8: " . join(l:errmsg), #{
  \ pos: 'topleft',
  \ line: 'cursor-3',
  \ col: winwidth(0)/4,
  \ moved: 'any',
  \ border: [],
  \ close: 'click'
  \ })
endfunction
