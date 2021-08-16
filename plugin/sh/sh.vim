" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" sh basic syntax check
" sh shellcheck syntax check

" do not read the file if is already loaded
if exists('g:loaded_sh') && g:loaded_sh == 1
  finish
endif
let g:loaded_sh = 1
let g:loaded_py3_sh = 0

" SHCheck
let s:sh_filebuff = "/tmp/".$USER."-vimbuff_sh_syntax.txt"
let s:sh_filesyntax = "/tmp/".$USER."-vimerr_sh_syntax.txt"

" SHShellCheck
let s:sh_shellcheckfilebuff = "/tmp/".$USER."-vimbuff_sh_shellchecksyntax.txt"
let s:sh_shellcheckfilesyntax = "/tmp/".$USER."-vimerr_sh_shellchecksyntax.txt"

" buffer is empty:
function! s:SHBufferIsEmpty()
    return (line('$') == 1 && getline(1) == '') ? 1 : 0
endfunction

" load sh.py
function! s:SHInit()
  if !exists('g:loaded_py3_sh') || (exists('g:loaded_py3_sh') && g:loaded_py3_sh == 0)
    py3file $HOME/.vim/plugin/sh/sh.py
    let g:loaded_py3_sh = 1
  endif
endfunction

" statusline
function! SHStatusLine()
  if exists("s:sh_error") && s:sh_error
    let l:output = "[SH=".s:sh_error."][SC]"
  elseif exists("s:sc_error") && s:sc_error
    let l:output = "[SH][SC=".s:sc_error."]"
  else
    let l:output = "[SH][SC]"
  endif
  return l:output
endfunction

" sh check
function! SHCheck(mode) abort
  if !s:SHBufferIsEmpty()
    try
      call s:SHInit()
      py3 sh_check(vim.eval("a:mode"))
    catch
      if a:mode ==# "read"
        echohl ErrorMsg
        echom "Error: (SHCheck) (read) function contains errors"
        echohl None
      elseif a:mode ==# "write"
        throw "Error: (SHCheck) (write) function contains errors"
      endif
    finally
      if a:mode ==# "write" && filereadable(s:sh_filebuff)
        call delete(s:sh_filebuff)
      endif
    endtry
  endif
endfunction

function! s:SHShellCheckNoExec()
  py3 sh_shellcheck_noexec()
endfunction

function! SHShellCheckAsync()
  " depends on SHCheck()
  if exists("s:sh_error") && s:sh_error
    echohl ErrorMsg
    echom "Error: (SHCheck) previous function contains errors"
    echom "Error: (SHShellCheckAsync) detected error"
    echohl None
    return
  endif
  if !s:SHBufferIsEmpty() && &filetype ==# "sh"
    let l:job = job_start("shellcheck --color=never " . bufname('%'), {"out_cb": "OutHandlerSHShellCheck", "err_cb": "ErrHandlerSHShellCheck", "exit_cb": "ExitHandlerSHShellCheck", "out_io": "file", "out_name": s:sh_shellcheckfilesyntax, "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! OutHandlerSHShellCheck(channel, message)
endfunction

function! ErrHandlerSHShellCheck(channel, message)
endfunction

function! ExitHandlerSHShellCheck(job, status)
  call s:SHShellCheckNoExec()
endfunction

" shows sh debug information
function! ShowSHDebugInfo()
  let l:curbufnr = winbufnr(winnr())
  let l:curline = line('.')

  redir => signsbuf
  silent execute ":sign place buffer=" . l:curbufnr
  redir END

  if !empty(signsbuf)
    for sb in split(signsbuf, "\n")
      if sb =~# "line=".l:curline." "
        if sb =~# "name=sh_error "
          call s:SHShowErrorPopup()
          break
        elseif sb =~# "name=sh_shellcheckerror "
          call s:SHShowShellCheckErrorPopup()
          break
        else
          throw "Error: unknown sign " . sb
        endif
      endif
    endfor
  endif

endfunction

" shows sh error popup
function! s:SHShowErrorPopup()
  let l:curline = line('.')
  let l:errmsg = systemlist("cut -d ':' -f2- " . s:sh_filesyntax . " | sed 's/^ //' | head -n1")

  echo "SH: " . join(l:errmsg)
  call popup_create("SH: " . join(l:errmsg), #{
  \ pos: 'topleft',
  \ line: 'cursor-3',
  \ col: winwidth(0)/4,
  \ moved: 'any',
  \ border: [],
  \ close: 'click'
  \ })
endfunction

" shows shellcheck error popup
function! s:SHShowShellCheckErrorPopup()
  let l:curline = line('.')
  let l:errmsg = systemlist("sed -n '/line " . l:curline . "/,/^$/p' " . s:sh_shellcheckfilesyntax . " | grep -v '^$' | tail -n1 | sed 's/   //g' | sed 's/  ^-- //'")

  echo "SC: " . join(l:errmsg)
  call popup_create("SC: " . join(l:errmsg), #{
  \ pos: 'topleft',
  \ line: 'cursor-3',
  \ col: winwidth(0)/4,
  \ moved: 'any',
  \ border: [],
  \ close: 'click'
  \ })
endfunction
