" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded or checker is not enabled
if exists('g:autoloaded_checker') || !get(g:, 'checker_enabled') || &cp
  finish
endif
let g:autoloaded_checker = 1

" script local errors
let s:checker_sh_errors = 0
let s:checker_sc_errors = 0
let s:checker_py_errors = 0
let s:checker_pep8_errors = 0
let s:checker_go_errors = 0
let s:checker_gv_errors = 0

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

""" SH """

" sh check
function! checker#SHCheck(file, mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = a:file
  let s:checker_sh_errors = 0
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
    let s:checker_sh_errors = 1
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
    " update local statusline
    let l:newstatusline = substitute(&statusline, '^\[SH=\d\]\[SC=\d\?{\?}\?\] ', "", "")
    let &l:statusline="[SH=".s:checker_sh_errors."][SC={}] " . l:newstatusline
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
function! s:SHShellCheckNoExec(file) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = a:file
  let s:checker_sc_errors = 0
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
    let s:checker_sc_errors = l:terrors
  endif
endfunction

" sh shellcheck async
function! checker#SHShellCheckAsync(file) abort
  " depends on checker#SHCheck()
  if s:checker_sh_errors
    call s:EchoErrorMsg("Error: (SHCheck) previous function contains errors")
    call s:EchoErrorMsg("Error: (SHShellCheckAsync) detected error"
    return
  endif
  if &filetype ==# "sh" && !s:BufferIsEmpty()
    let l:job = job_start("shellcheck --color=never " . a:file, {"out_cb": "checker#OutHandlerSHShellCheck", "err_cb": "checker#ErrHandlerSHShellCheck", "exit_cb": "checker#ExitHandlerSHShellCheck", "out_io": "file", "out_name": s:checkerfiles["sh"]["shellcheck"]["syntax"], "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function!  checker#OutHandlerSHShellCheck(channel, message) abort
endfunction

function! checker#ErrHandlerSHShellCheck(channel, message) abort
endfunction

function! checker#ExitHandlerSHShellCheck(job, status) abort
  let l:file = job_info(a:job)["cmd"][-1]
  call s:SHShellCheckNoExec(l:file)
  if filereadable(s:checkerfiles["sh"]["shellcheck"]["syntax"])
    if !getfsize(s:checkerfiles["sh"]["shellcheck"]["syntax"])
      call delete(s:checkerfiles["sh"]["shellcheck"]["syntax"])
    endif
    " update local statusline
    let l:newstatusline = substitute(&statusline, '^\[SH=\d\]\[SC=\d\?{\?}\?\] ', "", "")
    let &l:statusline="[SH=".s:checker_sh_errors."][SC=".s:checker_sc_errors."] " . l:newstatusline
  endif
endfunction

""" PYTHON """

" python check
function! checker#PYCheck(file, mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = a:file
  let s:checker_py_errors = 0
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
    let s:checker_py_errors = 1
    let l:errout = readfile(s:checkerfiles["python"]["python"]["syntax"])
    let l:errline = split(l:errout[4], ", line ")[1]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'py_error', l:curbufnr, {'lnum' : l:errline})
      call cursor(l:errline, 1)
    endif
    if a:mode ==# "write" && filereadable(s:checkerfiles["python"]["python"]["buffer"])
      call delete(s:checkerfiles["python"]["python"]["buffer"])
    endif
    " update local statusline
    let l:newstatusline = substitute(&statusline, '^\[PY=\d\]\[P8=\d\?{\?}\?\] ', "", "")
    let &l:statusline="[PY=".s:checker_py_errors."][P8={}] " . l:newstatusline
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
function! s:PYPep8NoExec(file) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = a:file
  let s:checker_pep8_errors = 0
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
    let s:checker_pep8_errors = l:terrors
  endif
endfunction

" python pep8 async
function! checker#PYPep8Async(file) abort
   " depends on checker#PYCheck()
  if s:checker_py_errors
    call s:EchoErrorMsg("Error: (PYCheck) previous function contains errors")
    call s:EchoErrorMsg("Error: (PYPep8Aysnc) detected error")
    return
  endif
  if &filetype ==# "python" && !s:BufferIsEmpty()
    let l:job = job_start("pep8 " . a:file, {"out_cb": "checker#OutHandlerPYPep8", "err_cb": "checker#ErrHandlerPYPep8", "exit_cb": "checker#ExitHandlerPYPep8", "out_io": "file", "out_name": s:checkerfiles["python"]["pep8"]["syntax"], "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! checker#OutHandlerPYPep8(channel, message) abort
endfunction

function! checker#ErrHandlerPYPep8(channel, message) abort
endfunction

function! checker#ExitHandlerPYPep8(job, status) abort
  let l:file = job_info(a:job)["cmd"][-1]
  call s:PYPep8NoExec(l:file)
  if filereadable(s:checkerfiles["python"]["pep8"]["syntax"])
    if !getfsize(s:checkerfiles["python"]["pep8"]["syntax"])
      call delete(s:checkerfiles["python"]["pep8"]["syntax"])
    endif
    " update local statusline
    let l:newstatusline = substitute(&statusline, '^\[PY=\d\]\[P8=\d\?{\?}\?\] ', "", "")
    let &l:statusline="[PY=".s:checker_py_errors."][P8=".s:checker_pep8_errors."] " . l:newstatusline
  endif
endfunction

""" GO """

" go check
function! checker#GOCheck(file, mode) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = a:file
  " let l:curline = line('.')
  let s:checker_go_errors = 0
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
    let s:checker_go_errors = 1
    let l:errout = trim(system("cut -d ':' -f2- " . s:checkerfiles["go"]["gofmt"]["syntax"] . " | head -n1"))
    let l:errline = split(l:errout, ":")[0]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'go_error', l:curbufnr, {'lnum' : l:errline})
      call cursor(l:errline, 1)
    endif
    if a:mode ==# "write" && filereadable(s:checkerfiles["go"]["gofmt"]["buffer"])
      call delete(s:checkerfiles["go"]["gofmt"]["buffer"])
    endif
    " update local statusline
    let l:newstatusline = substitute(&statusline, '^\[GO=\d\]\[GV=\d\?{\?}\?\] ', "", "")
    let &l:statusline="[GO=".s:checker_go_errors."][GV={}] " . l:newstatusline
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
function! s:GOVetNoExec(file) abort
  let l:curbufnr = winbufnr(winnr())
  let l:curbufname = a:file
  let s:checker_gv_errors = 0
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
    let s:checker_gv_errors = 1
    let l:errline = split(l:errout, ":")[0]
    if !empty(l:errline)
      call sign_place(l:errline, '', 'go_veterror', l:curbufnr, {'lnum' : l:errline})
    endif
  endif
endfunction

" go vet async
function! checker#GOVetAsync(file) abort
  " depends on checker#GoCheck()
   if s:checker_go_errors
     call s:EchoErrorMsg("Error: (GOCheck) previous function contains errors")
     call s:EchoErrorMsg("Error: (GOVetAsync) detected error")
     return
  endif
  if &filetype ==# "go" && !s:BufferIsEmpty()
    let l:job = job_start("go vet " . a:file, {"out_cb": "checker#OutHandlerGOVet", "err_cb": "checker#ErrHandlerGOVet", "exit_cb": "checker#ExitHandlerGOVet", "out_io": "file", "out_name": s:checkerfiles["go"]["govet"]["syntax"], "out_msg": 0, "out_modifiable": 0, "err_io": "out"})
  endif
endfunction

function! checker#OutHandlerGOVet(channel, message) abort
endfunction

function! checker#ErrHandlerGOVet(channel, message) abort
endfunction

function! checker#ExitHandlerGOVet(job, status) abort
  let l:file = job_info(a:job)["cmd"][-1]
  call s:GOVetNoExec(l:file)
  if filereadable(s:checkerfiles["go"]["govet"]["syntax"])
    if !getfsize(s:checkerfiles["go"]["govet"]["syntax"])
      call delete(s:checkerfiles["go"]["govet"]["syntax"])
    endif
    " update local statusline
    let l:newstatusline = substitute(&statusline, '^\[GO=\d\]\[GV=\d\?{\?}\?\] ', "", "")
    let &l:statusline="[GO=".s:checker_go_errors."][GV=".s:checker_gv_errors."] " . l:newstatusline
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
