" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if is already loaded
if exists('g:loaded_py3') && g:loaded_py3 == 1
  finish
endif
let g:loaded_py3 = 1
let g:loaded_init_py3 = 0

" PY3Check
let s:py3_filebuff = "/tmp/".$USER."-vimbuff_py_syntax.txt"
let s:py3_filesyntax = "/tmp/".$USER."-vimerr_py_syntax.txt"

" PY3Pep8
let s:py3_pep8filebuff = "/tmp/".$USER."-vimbuff_py_pep8syntax.txt"
let s:py3_pep8filesyntax = "/tmp/".$USER."-vimerr_py_pep8syntax.txt"

" buffer is empty:
function! s:PY3BufferIsEmpty()
  return (line('$') == 1 && getline(1) == '') ? 1 : 0
endfunction

" load python.py
function! s:PY3Init() abort
  if !exists('g:loaded_init_py3') || (exists('g:loaded_init_py3') && g:loaded_init_py3 == 0)
    py3file $HOME/.vim/plugin/python/python.py
    let g:loaded_init_py3 = 1
  endif
endfunction

" statusline
function! PY3StatusLine()
  if exists("s:py_error") && s:py_error
    let l:output = "[PY=".s:py_error."][P8]"
  elseif exists("s:pep8_error") && s:pep8_error
    let l:output = "[PY][P8=".s:pep8_error."]"
  else
    let l:output = "[PY][P8]"
  endif
  return l:output
endfunction

" basic check
function! PY3Check(mode) abort
  if !s:PY3BufferIsEmpty()
    try
      call s:PY3Init()
      py3 py3_check(vim.eval("a:mode"))
    catch
      if a:mode ==# "read"
        echohl ErrorMsg
        echom "Error: (PY3Check) (read) function contains errors"
        echohl None
      elseif a:mode ==# "write"
        throw "Error: (PY3Check) (write) function contains errors"
      endif
    finally
      if a:mode ==# "write" && filereadable(s:py3_filebuff)
        call delete(s:py3_filebuff)
      endif
    endtry
  endif
endfunction

function! s:PY3Pep8NoExec() abort
  py3 py3_pep8_noexec()
endfunction

function! PY3Pep8Async() abort
   " depends on PY3Check()
  if exists("s:py_error") && s:py_error
    echohl ErrorMsg
    echom "Error: (PY3Check) previous function contains errors"
    echom "Error: (PY3Pep8Async) detected error"
    echohl None
    return
  endif
  if !s:PY3BufferIsEmpty() && &filetype ==# "python"
    let l:job = job_start("pep8 " . bufname('%'), {"out_cb": "OutHandlerPY3Pep8", "err_cb": "ErrHandlerPY3Pep8", "exit_cb": "ExitHandlerPY3Pep8", "out_io": "file", "out_name": s:py3_pep8filesyntax, "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! OutHandlerPY3Pep8(channel, message) abort
endfunction

function! ErrHandlerPY3Pep8(channel, message) abort
endfunction

function! ExitHandlerPY3Pep8(job, status) abort
  call s:PY3Pep8NoExec()
endfunction

" shows py3 debug information
function! ShowPY3DebugInfo() abort
  let l:curbufnr = winbufnr(winnr())
  let l:curline = line('.')
  redir => signsbuf
  silent execute ":sign place buffer=" . l:curbufnr
  redir END
  if !empty(signsbuf)
    for sb in split(signsbuf, "\n")
      if sb =~# "line=".l:curline." "
        if sb =~# "name=py_error "
          call s:PY3ErrorPopup()
          break
        elseif sb =~# "name=py_pep8error "
          call s:PY3Pep8ErrorPopup()
          break
        else
          throw "Error: unknown sign " . sb
        endif
      endif
    endfor
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
