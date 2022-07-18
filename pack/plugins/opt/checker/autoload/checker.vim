" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded or checker is not enabled
if get(g:, 'autoloaded_checker') == 1 || get(g:, 'checker_enabled') == 0 || &cp
  finish
endif
let g:autoloaded_checker = 1

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

" user tmp directory
function! s:UserTempDir() abort
  let l:tmp = "/tmp"
  if !empty($TMPDIR)
    let l:tmp = $TMPDIR == "/" ? $TMPDIR : substitute($TMPDIR, "/$", "", "")
  endif
  return l:tmp
endfunction

" allowed file types
 let s:allowed_types = ["sh", "python", "go"]

" user tmp dir
let s:tmp = s:UserTempDir()

" sh, python, go
let s:checkerfiles = {
  \'sh' : {
    \'sh' : {
      \'buffer' :  s:tmp."/".$USER."-vim-checker_sh_sh_buffer.txt",
      \'syntax' : s:tmp."/".$USER."-vim-checker_sh_sh_syntax.txt"
    \},
    \'shellcheck' : {
      \'buffer' :  s:tmp."/".$USER."-vim-checker_sh_shellcheck_buffer.txt",
      \'syntax' : s:tmp."/".$USER."-vim-checker_sh_shellcheck_syntax.txt"
    \}
  \},
  \'python' : {
    \'python' : {
      \'buffer' :  s:tmp."/".$USER."-vim-checker_python_python_buffer.txt",
      \'syntax' : s:tmp."/".$USER."-vim-checker_python_python_syntax.txt"
    \},
    \'pep8' : {
      \'buffer' :  s:tmp."/".$USER."-vim-checker_python_pep8_buffer.txt",
      \'syntax' : s:tmp."/".$USER."-vim-checker_python_pep8_syntax.txt"
    \}
  \},
  \'go' : {
    \'gofmt' : {
      \'buffer' :  s:tmp."/".$USER."-vim-checker_go_gofmt_buffer.txt",
      \'syntax' : s:tmp."/".$USER."-vim-checker_go_gofmt_syntax.txt"
    \},
    \'govet' : {
      \'buffer' :  s:tmp."/".$USER."-vim-checker_go_govet_buffer.txt",
      \'syntax' : s:tmp."/".$USER."-vim-checker_go_govet_syntax.txt"
    \}
  \}
\}

" tells if buffer is empty
function! s:BufferIsEmpty() abort
  return line('$') == 1 && empty(getline(1))
endfunction

" shows debug information
function! checker#CycleSignsShowDebugInfo(type, mode) abort
  let l:curbuf = winbufnr(winnr())
  let l:curline = line('.')
  let l:curcycleline = 0
  let l:nextcycleline = 0
  let l:prevcycleline = 0
  let l:signameline = ""
  if index(s:allowed_types, a:type) == -1
    call s:EchoErrorMsg("Error: debug information for filetype '" . a:type . "' is not supported")
    return
  endif
  let l:signs = sign_getplaced(l:curbuf)[0].signs
  if empty(l:signs)
    call s:EchoWarningMsg("Warning: signs not found in the current buffer")
    return
  endif
  for l:sign in l:signs
    let l:cycleline = l:sign.lnum
    if a:mode ==# 'cur'
      let l:curcycleline = l:curline
      let l:signameline = l:sign.name
      break
    elseif a:mode ==# 'next'
      if l:curline < l:cycleline
        let l:nextcycleline = l:cycleline
        let l:signameline = l:sign.name
        break
      endif
    elseif a:mode ==# 'prev'
      if l:curline > l:cycleline
        let l:prevcycleline = l:cycleline
        let l:signameline = l:sign.name
      endif
    endif
  endfor
  if l:curcycleline || l:nextcycleline || l:prevcycleline
    if l:curcycleline
      try
        call sign_jump(l:curcycleline, '', l:curbuf)
      catch
        call s:EchoWarningMsg("Warning: sign id not found in line " . l:curcycleline)
        return
      endtry
    elseif l:nextcycleline
      try
        call sign_jump(l:nextcycleline, '', l:curbuf)
      catch
        call s:EchoWarningMsg("Warning: sign id not found in line " . l:nextcycleline)
        return
      endtry
    elseif l:prevcycleline
      try
        call sign_jump(l:prevcycleline, '', l:curbuf)
      catch
        call s:EchoWarningMsg("Warning: sign id not found in line " . l:prevcycleline)
        return
      endtry
    else
      call s:EchoErrorMsg("Error: sign jump line not found")
      return
    endif
    if index(s:allowed_types, a:type) >= 0
      call s:ShowDebugInfo(l:signameline, a:type)
    endif
  endif
endfunction

" statusline checker output
function! checker#StatusLine(type) abort
  if index(s:allowed_types, a:type) == -1
    return ""
  endif
  if a:type ==# "sh"
    if exists("s:sh_error") && s:sh_error
      let l:output = "[SH=".s:sh_error."]{SC}"
    elseif exists("s:sc_error") && s:sc_error
      let l:output = "[SH][SC=".s:sc_error."]"
    else
      let l:output = "[SH][SC]"
    endif
  elseif a:type ==# "python"
    if exists("s:py_error") && s:py_error
      let l:output = "[PY=".s:py_error."]{P8}"
    elseif exists("s:pep8_error") && s:pep8_error
      let l:output = "[PY][P8=".s:pep8_error."]"
    else
      let l:output = "[PY][P8]"
    endif
  elseif a:type ==# "go"
    if exists("s:go_error") && s:go_error
      let l:output = "[GO=".s:go_error."]{GV}"
    elseif exists("s:gv_error") && s:gv_error
      let l:output = "[GO][GV=".s:gv_error."]"
    else
      let l:output = "[GO][GV]"
    endif
  endif
  return l:output
endfunction

""" SH """

" sh check
function! checker#SHCheck(mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  let s:sh_error = 0
  if s:BufferIsEmpty() || !filereadable(l:curbufname)
    return
  endif
  if &filetype !=# "sh"
    throw "Error: (SHCheck) " . l:curbufname . " is not a valid sh file!"
  endif
  call s:RemoveSignsName(l:curbufnr, "sh_error")
  call s:RemoveSignsName(l:curbufnr, "sh_shellcheckerror")
  let l:theshell = getline(1) =~# "bash" ? "bash" : "sh"
  if a:mode ==# "read"
    let l:check_file = l:curbufname
  elseif a:mode ==# "write"
    silent execute "write! " . s:checkerfiles["sh"]["sh"]["buffer"]
    let l:check_file = s:checkerfiles["sh"]["sh"]["buffer"]
  endif
  if l:theshell ==# "sh"
    call system("sh -n " . l:check_file . " > " . s:checkerfiles["sh"]["sh"]["syntax"] . " 2>&1")
  elseif l:theshell ==# "bash"
    call system("bash --norc -n " . l:check_file . " > " . s:checkerfiles["sh"]["sh"]["syntax"] . " 2>&1")
  endif
  if v:shell_error != 0
    let s:sh_error = 1
    let l:errout = join(readfile(s:checkerfiles["sh"]["sh"]["syntax"]))
    let l:errline = substitute(trim(split(l:errout, ":")[1]), "^line ", "", "")
    echo l:errline
    if !empty(l:errline)
      call sign_place(l:errline, '', 'sh_error', l:curbufnr, {'lnum' : l:errline})
      call cursor(l:errline, 1)
    endif
    if a:mode ==# "write" && filereadable(s:checkerfiles["sh"]["sh"]["buffer"])
      call delete(s:checkerfiles["sh"]["sh"]["buffer"])
    endif
    throw "Error: (".a:mode.") " . l:errout
  endi
  if a:mode ==# "write" && filereadable(s:checkerfiles["sh"]["sh"]["buffer"])
    call delete(s:checkerfiles["sh"]["sh"]["buffer"])
  endif
  if filereadable(s:checkerfiles["sh"]["sh"]["syntax"])
  \&& !getfsize(s:checkerfiles["sh"]["sh"]["syntax"])
    call delete(s:checkerfiles["sh"]["sh"]["syntax"])
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
  if !filereadable(s:checkerfiles["sh"]["shellcheck"]["syntax"])
    " throw "Error: (SHShellCheckNoExec) ". s:checkerfiles["sh"]["shellcheck"]["syntax"] . " is not readable!"
    return
  endif
  call s:RemoveSignsName(l:curbufnr, "sh_shellcheckerror")
  let l:terrors = 0
  for l:line in readfile(s:checkerfiles["sh"]["shellcheck"]["syntax"])
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
function! checker#SHShellCheckAsync() abort
  " depends on checker#SHCheck()
  if exists("s:sh_error") && s:sh_error
    call s:EchoErrorMsg("Error: (SHCheck) previous function contains errors")
    call s:EchoErrorMsg("Error: (SHShellCheckAsync) detected error"
    return
  endif
  if &filetype ==# "sh" && !s:BufferIsEmpty()
    let l:job = job_start("shellcheck --color=never " . bufname('%'), {"out_cb": "OutHandlerSHShellCheck", "err_cb": "ErrHandlerSHShellCheck", "exit_cb": "ExitHandlerSHShellCheck", "out_io": "file", "out_name": s:checkerfiles["sh"]["shellcheck"]["syntax"], "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! OutHandlerSHShellCheck(channel, message) abort
endfunction

function! ErrHandlerSHShellCheck(channel, message) abort
endfunction

function! ExitHandlerSHShellCheck(job, status) abort
  call s:SHShellCheckNoExec()
  " TODO: without redraw
  if filereadable(s:checkerfiles["sh"]["shellcheck"]["syntax"])
    if !getfsize(s:checkerfiles["sh"]["shellcheck"]["syntax"])
      call delete(s:checkerfiles["sh"]["shellcheck"]["syntax"])
    endif
    redraw!
  endif
endfunction

""" PYTHON """

" python check
function! checker#PYCheck(mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  let s:py_error = 0
  if s:BufferIsEmpty() || !filereadable(l:curbufname)
    return
  endif
  if &filetype !=# "python"
    throw "error: (PYcheck) " . l:curbufname . " is not a valid python file!"
  endif
  call s:RemoveSignsName(l:curbufnr, "py_error")
  call s:RemoveSignsName(l:curbufnr, "py_pep8error")
  if a:mode ==# "read"
    let l:check_file = l:curbufname
  elseif a:mode ==# "write"
    silent execute "write! " . s:checkerfiles["python"]["python"]["buffer"]
    let l:check_file = s:checkerfiles["python"]["python"]["buffer"]
  endif
  call system("python3 -c \"import ast; ast.parse(open('". l:check_file ."').read())\" > " . s:checkerfiles["python"]["python"]["syntax"] . " 2>&1")
  if v:shell_error != 0
    let s:py_error = 1
    let l:errout = readfile(s:checkerfiles["python"]["python"]["syntax"])
    let l:errline = split(l:errout[4], ", line ")[1]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'py_error', l:curbufnr, {'lnum' : l:errline})
      call cursor(l:errline, 1)
    endif
    if a:mode ==# "write" && filereadable(s:checkerfiles["python"]["python"]["buffer"])
      call delete(s:checkerfiles["python"]["python"]["buffer"])
    endif
    throw "Error: (".a:mode.") " . l:errout
  endif
  if a:mode ==# "write" && filereadable(s:checkerfiles["python"]["python"]["buffer"])
    call delete(s:checkerfiles["python"]["python"]["buffer"])
  endif
  if filereadable(s:checkerfiles["python"]["python"]["syntax"])
  \&& !getfsize(s:checkerfiles["python"]["python"]["syntax"])
    call delete(s:checkerfiles["python"]["python"]["syntax"])
  endif
endfunction

" python pep8 (no exec)
function! s:PYPep8NoExec() abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  let s:pep8_error = 0
  if &filetype !=# "python"
    throw "Error: (PYPep8NoExec) " . l:curbufname . " is not a valid python file!"
  endif
  if !filereadable(s:checkerfiles["python"]["pep8"]["syntax"])
    " throw "Error: (PYPep8NoExec) ". s:checkerfiles["python"]["pep8"]["syntax"] . " is not readable!"
    return
  endif
  call s:RemoveSignsName(l:curbufnr, "py_pep8error")
  let l:terrors = 0
  for l:line in readfile(s:checkerfiles["python"]["pep8"]["syntax"])
    " pep8 shows now a warning that has been renamed to pycodestyle
    if l:line !~# "^".l:curbufname.":"
      continue
    endif
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

" python pep8 async
function! checker#PYPep8Async() abort
   " depends on checker#PYCheck()
  if exists("s:py_error") && s:py_error
    call s:EchoErrorMsg("Error: (PYCheck) previous function contains errors")
    call s:EchoErrorMsg("Error: (PYPep8Aysnc) detected error")
    return
  endif
  if &filetype ==# "python" && !s:BufferIsEmpty()
    let l:job = job_start("pep8 " . bufname('%'), {"out_cb": "OutHandlerPYPep8", "err_cb": "ErrHandlerPYPep8", "exit_cb": "ExitHandlerPYPep8", "out_io": "file", "out_name": s:checkerfiles["python"]["pep8"]["syntax"], "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! OutHandlerPYPep8(channel, message) abort
endfunction

function! ErrHandlerPYPep8(channel, message) abort
endfunction

function! ExitHandlerPYPep8(job, status) abort
  call s:PYPep8NoExec()
  " TODO: without redraw
  if filereadable(s:checkerfiles["python"]["pep8"]["syntax"])
    if !getfsize(s:checkerfiles["python"]["pep8"]["syntax"])
      call delete(s:checkerfiles["python"]["pep8"]["syntax"])
    endif
    redraw!
  endif
endfunction

""" GO """

" go check
function! checker#GOCheck(mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = bufname('%')
  " let l:curline = line('.')
  let s:go_error = 0
  if s:BufferIsEmpty() || !filereadable(l:curbufname)
    return
  endif
  if &filetype !=# "go"
    throw "Error: (GOCheck) " . l:curbufname . " is not a valid go file!"
  endif
  if !executable("gofmt")
    throw "Error: (GOCheck) program gofmt is missing!"
  endif
  " TODO: recheck
  " sign_unplace() does not support 'name' : 'error_name'
  " call sign_unplace('', {'buffer' : l:curbufnr, 'id' : l:curline})
  call s:RemoveSignsName(l:curbufnr, "go_error")
  call s:RemoveSignsName(l:curbufnr, "go_veterror")
  if a:mode ==# "read"
    let l:check_file = l:curbufname
  elseif a:mode ==# "write"
    silent execute "write! " . s:checkerfiles["go"]["gofmt"]["buffer"]
    let l:check_file = s:checkerfiles["go"]["gofmt"]["buffer"]
  endif
  " send to stderr, goftm puts all output file in stdout
  call system("gofmt -e " . l:check_file . " 2>  " . s:checkerfiles["go"]["gofmt"]["syntax"])
  if v:shell_error != 0
    let s:go_error = 1
    let l:errout = trim(system("cut -d ':' -f2- " . s:checkerfiles["go"]["gofmt"]["syntax"] . " | head -n1"))
    let l:errline = split(l:errout, ":")[0]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'go_error', l:curbufnr, {'lnum' : l:errline})
      call cursor(l:errline, 1)
    endif
    if a:mode ==# "write" && filereadable(s:checkerfiles["go"]["gofmt"]["buffer"])
      call delete(s:checkerfiles["go"]["gofmt"]["buffer"])
    endif
    throw "Error: (".a:mode.") " . l:errout
  endif
  if a:mode ==# "write" && filereadable(s:checkerfiles["go"]["gofmt"]["buffer"])
    call delete(s:checkerfiles["go"]["gofmt"]["buffer"])
  endif
  if filereadable(s:checkerfiles["go"]["gofmt"]["syntax"])
  \&& !getfsize(s:checkerfiles["go"]["gofmt"]["syntax"])
    call delete(s:checkerfiles["go"]["gofmt"]["syntax"])
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
  if !filereadable(s:checkerfiles["go"]["govet"]["syntax"])
    " throw "Error: (GOVetNoExec) ". s:checkerfiles["go"]["govet"]["syntax"] . " is not readable!"
    return
  endif
  call s:RemoveSignsName(l:curbufnr, "go_veterror")
  let l:errout = trim(system("grep '^vet: ' " . s:checkerfiles["go"]["govet"]["syntax"] . " | cut -d ':' -f3- | head -n1"))
  " some errors are with ^filename (not ^vet)
  if empty(l:errout)
    let l:errout = trim(system("grep ^" . l:curbufname . ":" . " " . s:checkerfiles["go"]["govet"]["syntax"] . " | cut -d ':' -f2- | head -n1"))
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
function! checker#GOVetAsync() abort
  " depends on checker#GoCheck()
   if exists("s:go_error") && s:go_error
     call s:EchoErrorMsg("Error: (GOCheck) previous function contains errors")
     call s:EchoErrorMsg("Error: (GOVetAsync) detected error")
     return
  endif
  if &filetype ==# "go" && !s:BufferIsEmpty()
    let l:job = job_start("go vet " . bufname('%'), {"out_cb": "OutHandlerGOVet", "err_cb": "ErrHandlerGOVet", "exit_cb": "ExitHandlerGOVet", "out_io": "file", "out_name": s:checkerfiles["go"]["govet"]["syntax"], "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! OutHandlerGOVet(channel, message) abort
endfunction

function! ErrHandlerGOVet(channel, message) abort
endfunction

function! ExitHandlerGOVet(job, status) abort
  call s:GOVetNoExec()
  " TODO: without redraw
  if filereadable(s:checkerfiles["go"]["govet"]["syntax"])
    if !getfsize(s:checkerfiles["go"]["govet"]["syntax"])
      call delete(s:checkerfiles["go"]["govet"]["syntax"])
    endif
    redraw!
  endif
endfunction

" remove signs
function! s:RemoveSignsName(buf, name)
  let l:signs = sign_getplaced(a:buf)[0].signs
  if empty(l:signs)
    return
  endif
  for l:sign in l:signs
    if l:sign.name ==# a:name
      call sign_unplace('', {'buffer' : a:buf, 'id' : l:sign.id})
    endif
  endfor
endfunction

" shows debug information
function! s:ShowDebugInfo(signame, type) abort
  if a:type ==# "sh"
    if a:signame ==# "sh_error"
      call s:ShowErrorPopup("sh")
    elseif a:signame ==# "sh_shellcheckerror"
      call s:ShowErrorPopup("shellcheck")
    else
      throw "Error: unknown sign " . a:signame
    endif
  elseif a:type ==# "python"
    if a:signame ==# "py_error"
      call s:ShowErrorPopup("python")
    elseif a:signame ==# "py_pep8error"
      call s:ShowErrorPopup("pep8")
    else
      throw "Error: unknown sign " . a:signame
    endif
  elseif a:type ==# "go"
    if a:signame ==# "go_error"
      call s:ShowErrorPopup("go")
    elseif a:signame ==# "go_veterror"
      call s:ShowErrorPopup("go vet")
    else
      throw "Error: unknown sign " . a:signame
    endif
  endif
endfunction

" shows error popup
function! s:ShowErrorPopup(type) abort
  let l:curline = line('.')
  if a:type ==# "sh"
    let l:errmsg = systemlist("cut -d ':' -f2- " . s:checkerfiles["sh"]["sh"]["syntax"] . " | sed 's/^ //' | head -n1")
  elseif a:type ==# "shellcheck"
    let l:errmsg = systemlist("sed -n '/line " . l:curline . "/,/^$/p' " . s:checkerfiles["sh"]["shellcheck"]["syntax"] . " | grep -v '^$' | tail -n1 | sed 's/   //g' | sed 's/  ^-- //'")
  elseif a:type ==# "python"
    let l:errmsg = systemlist("cat " . s:checkerfiles["python"]["python"]["syntax"])
  elseif a:type ==# "pep8"
    let l:errmsg = systemlist("grep -E ':".l:curline.":.*: ' " . s:checkerfiles["python"]["pep8"]["syntax"] . " | cut -d ' ' -f2-")
  elseif a:type ==# "go"
    let l:errmsg = systemlist("grep -F :". l:curline . ":" . " " . s:checkerfiles["go"]["gofmt"]["syntax"] . " | cut -d ':' -f2-")
  elseif a:type ==# "go vet"
    let l:errmsg = systemlist("grep -F :". l:curline . ":" . " " . s:checkerfiles["go"]["govet"]["syntax"])
  endif
  echo a:type . ": " . join(l:errmsg)
  call popup_create(a:type . ": " . join(l:errmsg), #{
  \ pos: 'topleft',
  \ line: 'cursor-3',
  \ col: winwidth(0)/4,
  \ moved: 'any',
  \ border: [],
  \ close: 'click'
  \ })
endfunction
