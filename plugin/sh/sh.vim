" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" sh basic syntax check
" sh shellcheck syntax check

" do not read the file if is already loaded
if exists('g:loaded_sh') && g:loaded_sh == 1
  finish
endif
let g:loaded_sh = 1

" user tmp dir
let s:tmp = UserTempDir()

" sh check
let s:sh_filebuff = s:tmp."/".$USER."-vimbuff_sh_syntax.txt"
let s:sh_filesyntax = s:tmp."/".$USER."-vimerr_sh_syntax.txt"

" sh shellcheck
let s:sh_shellcheckfilebuff = s:tmp."/".$USER."-vimbuff_sh_shellchecksyntax.txt"
let s:sh_shellcheckfilesyntax = s:tmp."/".$USER."-vimerr_sh_shellchecksyntax.txt"

" checks if buffer is empty
function! s:SHBufferIsEmpty() abort
  return (line('$') == 1 && getline(1) == '') ? 1 : 0
endfunction

" for statusline
function! g:SHStatusLine() abort
  if exists("s:sh_error") && s:sh_error
    let l:output = "[SH=".s:sh_error."]{SC}"
  elseif exists("s:sc_error") && s:sc_error
    let l:output = "[SH][SC=".s:sc_error."]"
  else
    let l:output = "[SH][SC]"
  endif
  return l:output
endfunction

" sh check
function! g:SHCheck(mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  let s:sh_error = 0
  if s:SHBufferIsEmpty()
    return
  endif
  if &filetype !=# "sh"
    throw "Error: (SHCheck) " . l:curbufname . " is not a valid sh file!"
  endif
  call RemoveSignsName(l:curbufnr, "sh_error")
  call RemoveSignsName(l:curbufnr, "sh_shellcheckerror")
  let l:theshell="sh"
  let l:shebang = readfile(l:curbufname)[0]
  if l:shebang =~# "bash$"
    let l:theshell="bash"
  endif
  if a:mode ==# "read"
    let l:check_file = l:curbufname
  elseif a:mode ==# "write"
    silent execute "write! " . s:sh_filebuff
    let l:check_file = s:sh_filebuff
  endif
  if l:theshell ==# "sh"
    call system("sh -n " . l:check_file . " > " . s:sh_filesyntax . " 2>&1")
  elseif l:theshell ==# "bash"
    call system("bash --norc -n " . l:check_file . " > " . s:sh_filesyntax . " 2>&1")
  endif
  if v:shell_error != 0
    let s:sh_error = 1
    let l:errout = join(readfile(s:sh_filesyntax))
    let l:errline = substitute(trim(split(l:errout, ":")[1]), "^line ", "", "")
    echo l:errline
    if !empty(l:errline)
      call sign_place(l:errline, '', 'sh_error', l:curbufnr, {'lnum' : l:errline})
      call cursor(l:errline, 1)
    endif
    if a:mode ==# "write" && filereadable(s:sh_filebuff)
      call delete(s:sh_filebuff)
    endif
    throw "Error: (".a:mode.") " . l:errout
  endif
  if a:mode ==# "write" && filereadable(s:sh_filebuff)
    call delete(s:sh_filebuff)
  endif
endfunction

" sh shellcheck (no exec)
function! s:SHShellCheckNoExec() abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  let s:sc_error = 0
  if &filetype !=# "sh"
    throw "Error: (SHCheck) " . l:curbufname . " is not a valid sh file!"
  endif
  if !filereadable(s:sh_shellcheckfilesyntax)
    throw "Error: (SHShellCheckNoExec) ". s:sh_shellcheckfilesyntax . " is not readable!"
  endif
  call RemoveSignsName(l:curbufnr, "sh_shellcheckerror")
  let l:terrors = 0
  for l:line in readfile(s:sh_shellcheckfilesyntax)
    if l:line =~# "^In "
      let l:errline = split(split(l:line, " ")[3], ":")[0]
      if !empty(l:errline)
        call sign_place(l:errline, '', 'sh_shellcheckerror', l:curbufnr, {'lnum' : l:errline})
      endif
      let l:terrors += 1
    endif
  endfor
  if l:terrors
    let s:sc_error = l:terrors
  endif
endfunction

" sh shellcheck async
function! g:SHShellCheckAsync() abort
  " depends on SHCheck()
  if exists("s:sh_error") && s:sh_error
    echohl ErrorMsg
    echom "Error: (SHCheck) previous function contains errors"
    echom "Error: (SHShellCheckAsync) detected error"
    echohl None
    return
  endif
  if !s:SHBufferIsEmpty() && &filetype ==# "sh"
    let l:job = job_start("shellcheck --color=never " . bufname('%'), {"out_cb": "OutHandlerSHShellCheck", "err_cb": "ErrHandlerSHShellCheck", "exit_cb": "s:ExitHandlerSHShellCheck", "out_io": "file", "out_name": s:sh_shellcheckfilesyntax, "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! s:OutHandlerSHShellCheck(channel, message) abort
endfunction

function! s:ErrHandlerSHShellCheck(channel, message) abort
endfunction

function! s:ExitHandlerSHShellCheck(job, status) abort
  call s:SHShellCheckNoExec()
  " TODO: recheck if necessary
  redraw!
endfunction

" shows debug information
function! g:ShowSHDebugInfo(signame) abort
  if a:signame ==# "sh_error"
    call s:SHShowErrorPopup()
  elseif a:signame ==# "sh_shellcheckerror"
    call s:SHShowShellCheckErrorPopup()
  else
    throw "Error: unknown sign " . a:signame
  endif
endfunction

" shows sh error popup
function! s:SHShowErrorPopup() abort
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
function! s:SHShowShellCheckErrorPopup() abort
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
