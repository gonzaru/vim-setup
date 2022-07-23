vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or checker is not enabled
if exists('g:autoloaded_checker') || !get(g:, 'checker_enabled') || &cp
  finish
endif
g:autoloaded_checker = 1

# checker errors
final CHECKER_ERRORS = {
  'sh': {
    'sh': 0,
    'shellcheck': 0
  },
  'python': {
    'python': 0,
    'pep8': 0
  },
  'go': {
    'gofmt': 0,
    'govet': 0
  }
}

# job queues
final JOB_QUEUE = {
  'sh': {
    'shellcheck': []
  },
  'python': {
    'pep8': []
  },
  'go': {
    'govet': []
  }
}

# statusline regex
const REGEX_STATUSLINE = {
  'sh': '^\[SH=\d*\]\[SC=\d*N\?E\?\] ',
  'python': '^\[PY=\d*\]\[P8=\d*N\?E\?\] ',
  'go': '^\[GO=\d*\]\[GV=\d*N\?E\?\] '
}

# user tmp directory
const TMPDIR = !empty($TMPDIR) ? ($TMPDIR == "/" ? $TMPDIR : substitute($TMPDIR, "/$", "", "")) : "/tmp"

# checker files
const CHECKER_FILES = {
  'sh': {
    'sh': {
      'buffer': TMPDIR .. "/" .. $USER .. "-vim-checker_sh_sh_buffer.txt",
      'syntax': TMPDIR .. "/" .. $USER .. "-vim-checker_sh_sh_syntax.txt"
    },
    'shellcheck': {
      'buffer': TMPDIR .. "/" .. $USER .. "-vim-checker_sh_shellcheck_buffer.txt",
      'syntax': TMPDIR .. "/" .. $USER .. "-vim-checker_sh_shellcheck_syntax.txt"
    }
  },
  'python': {
    'python': {
      'buffer': TMPDIR .. "/" .. $USER .. "-vim-checker_python_python_buffer.txt",
      'syntax': TMPDIR .. "/" .. $USER .. "-vim-checker_python_python_syntax.txt"
    },
    'pep8': {
      'buffer': TMPDIR .. "/" .. $USER .. "-vim-checker_python_pep8_buffer.txt",
      'syntax': TMPDIR .. "/" .. $USER .. "-vim-checker_python_pep8_syntax.txt"
    }
  },
  'go': {
    'gofmt': {
      'buffer': TMPDIR .. "/" .. $USER .. "-vim-checker_go_gofmt_buffer.txt",
      'syntax': TMPDIR .. "/" .. $USER .. "-vim-checker_go_gofmt_syntax.txt"
    },
    'govet': {
      'buffer': TMPDIR .. "/" .. $USER .. "-vim-checker_go_govet_buffer.txt",
      'syntax': TMPDIR .. "/" .. $USER .. "-vim-checker_go_govet_syntax.txt"
    }
  }
}

# prints error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom  msg
    echohl None
  endif
enddef

# prints warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom  msg
    echohl None
  endif
enddef

# tells if buffer is empty
def BufferIsEmpty(): bool
  return line('$') == 1 && empty(getline(1))
enddef

# remove signs
# sign_unplace() does not support 'name' : 'error_name'
# deprecated: now sign_unplace() has support to unplace by name
# def RemoveSignsName(buf: number, name: string)
#   var signs = sign_getplaced(buf)[0].signs
#   if empty(signs)
#     return
#   endif
#   for sign in signs
#     if sign.name == name
#       sign_unplace('', {'buffer': buf, 'id': sign.id})
#     endif
#   endfor
# enddef

# """ SH """

# sh check
export def SHCheck(file: string, mode: string): void
  var curbufnr = winbufnr(winnr())
  var curbufname = file
  var theshell: string
  var check_file: string
  var errout: string
  var errline: number
  var prevstatusline: string
  if !get(g:, 'checker_enabled')
    return
  endif
  if BufferIsEmpty() || !filereadable(curbufname)
    return
  endif
  if &filetype != "sh"
    throw "Error: (SHCheck) " .. curbufname .. " is not a valid sh file!"
  endif
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['sh']['sh']})
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['sh']['shellcheck']})
  CHECKER_ERRORS['sh']['sh'] = 0
  theshell = getline(1) =~ "bash" ? "bash" : "sh"
  if mode == "read"
    check_file = curbufname
  elseif mode == "write"
    silent execute "write! " .. CHECKER_FILES["sh"]["sh"]["buffer"]
    check_file = CHECKER_FILES["sh"]["sh"]["buffer"]
  endif
  if theshell == "sh"
    system("sh -n " .. check_file .. " > " .. CHECKER_FILES["sh"]["sh"]["syntax"] .. " 2>&1")
  elseif theshell == "bash"
    system("bash --norc -n " .. check_file .. " > " .. CHECKER_FILES["sh"]["sh"]["syntax"] .. " 2>&1")
  endif
  if v:shell_error != 0
    CHECKER_ERRORS['sh']['sh'] = 1
    errout = join(readfile(CHECKER_FILES["sh"]["sh"]["syntax"]))
    errline = str2nr(substitute(trim(split(errout, ":")[1]), "^line ", "", ""))
    if !empty(errline)
      sign_place(errline, '', g:CHECKER_SIGNS_ERRORS['sh']['sh'], curbufnr, {'lnum': errline})
      cursor(errline, 1)
    endif
    if mode == "write" && filereadable(CHECKER_FILES["sh"]["sh"]["buffer"])
      delete(CHECKER_FILES["sh"]["sh"]["buffer"])
    endif
    # update local statusline
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['sh'], "", "")
    &l:statusline = "[SH=" .. CHECKER_ERRORS['sh']['sh'] .. "][SC=N] " .. prevstatusline
    throw "Error: (" .. mode .. ") " .. errout
  endif
  if mode == "write" && filereadable(CHECKER_FILES["sh"]["sh"]["buffer"])
    delete(CHECKER_FILES["sh"]["sh"]["buffer"])
  endif
  if filereadable(CHECKER_FILES["sh"]["sh"]["syntax"]) && !getfsize(CHECKER_FILES["sh"]["sh"]["syntax"])
    delete(CHECKER_FILES["sh"]["sh"]["syntax"])
  endif
enddef

# sh shellcheck (no exec)
def SHShellCheckNoExec(file: string): void
  var curbufnr = winbufnr(winnr())
  var curbufname = file
  var terrors: number
  var errline: number
  CHECKER_ERRORS['sh']['sc'] = 0
  if &filetype != "sh"
    throw "Error: (SHCheck) " .. curbufname .. " is not a valid sh file!"
  endif
  if !filereadable(CHECKER_FILES["sh"]["shellcheck"]["syntax"])
    # throw "Error: (SHShellCheckNoExec) ". s:checkerfiles["sh"]["shellcheck"]["syntax"] . " is not readable!"
    return
  endif
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['sh']['shellcheck']})
  terrors = 0
  for line in readfile(CHECKER_FILES["sh"]["shellcheck"]["syntax"])
    if line =~ "^In "
      errline = str2nr(split(split(line, " ")[3], ":")[0])
      if !empty(errline)
        sign_place(errline, '', g:CHECKER_SIGNS_ERRORS['sh']['shellcheck'], curbufnr, {'lnum': errline})
      endif
      terrors += 1
    endif
  endfor
  if terrors > 0
    CHECKER_ERRORS['sh']['sc'] = terrors
  endif
enddef

# sh shellcheck async
export def SHShellCheckAsync(file: string): void
  var newjob: job
  if !get(g:, 'checker_enabled')
    return
  endif
  # depends on checker#SHCheck()
  if CHECKER_ERRORS['sh']['sh']
    EchoErrorMsg("Error: (SHCheck) previous function contains errors")
    EchoErrorMsg("Error: (SHShellCheckAsync) detected error")
    return
  endif
  if &filetype == "sh" && !BufferIsEmpty() && empty(JOB_QUEUE['sh']['shellcheck'])
    newjob = job_start(
      ['shellcheck', '--color=never', file],
      {
        "out_cb": "s:OutHandlerSHShellCheck",
        "err_cb": "s:ErrHandlerSHShellCheck",
        "exit_cb": "s:ExitHandlerSHShellCheck",
        "out_io": "file",
        "out_name": CHECKER_FILES["sh"]["shellcheck"]["syntax"],
        "out_msg": 0,
        "out_modifiable": 0,
        "err_io": "out"
      }
    )
    add(JOB_QUEUE['sh']['shellcheck'], job_info(newjob)['process'])
  endif
enddef

# def OutHandlerSHShellCheck(channel: channel, message: string)
# enddef

# def ErrHandlerSHShellCheck(channel: channel, message: string)
# enddef

def ExitHandlerSHShellCheck(job: job, status: number)
  var file = job_info(job)["cmd"][-1]
  var idx: number
  var prevstatusline: string
  SHShellCheckNoExec(file)
  if filereadable(CHECKER_FILES["sh"]["shellcheck"]["syntax"])
    if !getfsize(CHECKER_FILES["sh"]["shellcheck"]["syntax"])
      delete(CHECKER_FILES["sh"]["shellcheck"]["syntax"])
    endif
    # update local statusline
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['sh'], "", "")
    &l:statusline = "[SH=" .. CHECKER_ERRORS['sh']['sh'] .. "][SC=" .. CHECKER_ERRORS['sh']['sc'] .. "] " .. prevstatusline
  endif
  # job command with unexpected error
  if !CHECKER_ERRORS['sh']['sc'] && job_info(job)["exitval"] != 0
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['sh'], "", "")
    &l:statusline = "[SH=" .. CHECKER_ERRORS['sh']['sh'] .. "][SC=E] " .. prevstatusline
  endif
  idx = index(JOB_QUEUE['sh']['shellcheck'], job_info(job)["process"])
  if idx >= 0
    remove(JOB_QUEUE['sh']['shellcheck'], idx)
  endif
enddef

# """ PYTHON """

# python check
export def PYCheck(file: string, mode: string): void
  var curbufnr = winbufnr(winnr())
  var curbufname = file
  var check_file: string
  var errout: list<string>
  var errline: number
  var prevstatusline: string
  if !get(g:, 'checker_enabled')
    return
  endif
  if BufferIsEmpty() || !filereadable(curbufname)
    return
  endif
  if &filetype != "python"
    throw "error: (PYcheck) " .. curbufname .. " is not a valid python file!"
  endif
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['python']['python']})
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['python']['pep8']})
  CHECKER_ERRORS['python']['python'] = 0
  if mode == "read"
    check_file = curbufname
  elseif mode == "write"
    silent execute "write! " .. CHECKER_FILES["python"]["python"]["buffer"]
    check_file = CHECKER_FILES["python"]["python"]["buffer"]
  endif
  system("python3 -c \"import ast; ast.parse(open('" .. check_file .. "').read())\" > " .. CHECKER_FILES["python"]["python"]["syntax"] .. " 2>&1")
  if v:shell_error != 0
    CHECKER_ERRORS['python']['python'] = 1
    errout = readfile(CHECKER_FILES["python"]["python"]["syntax"])
    errline = str2nr(split(errout[4], ", line ")[1])
    if !empty(errline)
      sign_place(errline, '', g:CHECKER_SIGNS_ERRORS['python']['python'], curbufnr, {'lnum': errline})
      cursor(errline, 1)
    endif
    if mode == "write" && filereadable(CHECKER_FILES["python"]["python"]["buffer"])
      delete(CHECKER_FILES["python"]["python"]["buffer"])
    endif
    # update local statusline
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['python'], "", "")
    &l:statusline = "[PY=" .. CHECKER_ERRORS['python']['python'] .. "][P8=N] " .. prevstatusline
    throw "Error: (" .. mode .. ") " .. join(errout)
  endif
  if mode == "write" && filereadable(CHECKER_FILES["python"]["python"]["buffer"])
    delete(CHECKER_FILES["python"]["python"]["buffer"])
  endif
  if filereadable(CHECKER_FILES["python"]["python"]["syntax"]) && !getfsize(CHECKER_FILES["python"]["python"]["syntax"])
    delete(CHECKER_FILES["python"]["python"]["syntax"])
  endif
enddef

# python pep8 (no exec)
def PYPep8NoExec(file: string): void
  var curbufnr = winbufnr(winnr())
  var curbufname = file
  var terrors: number
  var errline: number
  CHECKER_ERRORS['python']['pep8'] = 0
  if &filetype != "python"
    throw "Error: (PYPep8NoExec) " .. curbufname .. " is not a valid python file!"
  endif
  if !filereadable(CHECKER_FILES["python"]["pep8"]["syntax"])
    # throw "Error: (PYPep8NoExec) ". s:checkerfiles["python"]["pep8"]["syntax"] . " is not readable!"
    return
  endif
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['python']['pep8']})
  terrors = 0
  for line in readfile(CHECKER_FILES["python"]["pep8"]["syntax"])
    # pep8 shows now a warning that has been renamed to pycodestyle
    if line !~ "^" .. curbufname .. ":"
      continue
    endif
    errline = str2nr(split(line, ":")[1])
    if !empty(errline)
      sign_place(errline, '', g:CHECKER_SIGNS_ERRORS['python']['pep8'], curbufnr, {'lnum': errline})
    endif
    terrors += 1
  endfor
  if terrors > 0
    CHECKER_ERRORS['python']['pep8'] = terrors
  endif
enddef

# python pep8 async
export def PYPep8Async(file: string): void
  var newjob: job
  if !get(g:, 'checker_enabled')
    return
  endif
  # depends on checker#PYCheck()
  if CHECKER_ERRORS['python']['python']
    EchoErrorMsg("Error: (PYCheck) previous function contains errors")
    EchoErrorMsg("Error: (PYPep8Aysnc) detected error")
    return
  endif
  if &filetype == "python" && !BufferIsEmpty() && empty(JOB_QUEUE['python']['pep8'])
    newjob = job_start(
      ['pep8', file],
      {
        "out_cb": "s:OutHandlerPYPep8",
        "err_cb": "s:ErrHandlerPYPep8",
        "exit_cb": "s:ExitHandlerPYPep8",
        "out_io": "file",
        "out_name": CHECKER_FILES["python"]["pep8"]["syntax"],
        "out_msg": 0,
        "out_modifiable": 0,
        "err_io": "out"
      }
    )
    add(JOB_QUEUE['python']['pep8'], job_info(newjob)['process'])
  endif
enddef

# def OutHandlerPYPep8(channel: channel, message: string)
# enddef

# def ErrHandlerPYPep8(channel: channel, message: string)
# enddef

def ExitHandlerPYPep8(job: job, status: number)
  var file = job_info(job)["cmd"][-1]
  var idx: number
  var prevstatusline: string
  PYPep8NoExec(file)
  if filereadable(CHECKER_FILES["python"]["pep8"]["syntax"])
    if !getfsize(CHECKER_FILES["python"]["pep8"]["syntax"])
      delete(CHECKER_FILES["python"]["pep8"]["syntax"])
    endif
    # update local statusline
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['python'], "", "")
    &l:statusline = "[PY=" .. CHECKER_ERRORS['python']['python'] .. "][P8=" .. CHECKER_ERRORS['python']['pep8'] .. "] " .. prevstatusline
  endif
  # job command with unexpected error
  if !CHECKER_ERRORS['python']['pep8'] && job_info(job)["exitval"] != 0
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['python'], "", "")
    &l:statusline = "[PY=" .. CHECKER_ERRORS['python']['python'] .. "][P8=E] " .. prevstatusline
  endif
  idx = index(JOB_QUEUE['python']['pep8'], job_info(job)["process"])
  if idx >= 0
    remove(JOB_QUEUE['python']['pep8'], idx)
  endif
enddef

# """ GO """

# go check
export def GOCheck(file: string, mode: string): void
  var curbufnr = winbufnr(winnr())
  var curbufname = file
  var check_file: string
  var errout: string
  var errline: number
  var prevstatusline: string
  if !get(g:, 'checker_enabled')
    return
  endif
  if BufferIsEmpty() || !filereadable(curbufname)
    return
  endif
  if &filetype != "go"
    throw "Error: (GOCheck) " .. curbufname .. " is not a valid go file!"
  endif
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['go']['gofmt']})
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['go']['govet']})
  CHECKER_ERRORS['go']['gofmt'] = 0
  if mode == "read"
    check_file = curbufname
  elseif mode == "write"
    silent execute "write! " .. CHECKER_FILES["go"]["gofmt"]["buffer"]
    check_file = CHECKER_FILES["go"]["gofmt"]["buffer"]
  endif
  # send to stderr, goftm puts all output file in stdout
  system("gofmt -e " .. check_file .. " 2>  " .. CHECKER_FILES["go"]["gofmt"]["syntax"])
  if v:shell_error != 0
    CHECKER_ERRORS['go']['gofmt'] = 1
    errout = trim(system("cut -d ':' -f2- " .. CHECKER_FILES["go"]["gofmt"]["syntax"] .. " | head -n1"))
    errline = str2nr(split(errout, ":")[0])
    if !empty(errline)
      sign_place(errline, '', g:CHECKER_SIGNS_ERRORS['go']['gofmt'], curbufnr, {'lnum': errline})
      cursor(errline, 1)
    endif
    if mode == "write" && filereadable(CHECKER_FILES["go"]["gofmt"]["buffer"])
      delete(CHECKER_FILES["go"]["gofmt"]["buffer"])
    endif
    # update local statusline
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['go'], "", "")
    &l:statusline = "[GO=" .. CHECKER_ERRORS['go']['gofmt'] .. "][GV=N] " .. prevstatusline
    throw "Error: (" .. mode .. ") " .. errout
  endif
  if mode == "write" && filereadable(CHECKER_FILES["go"]["gofmt"]["buffer"])
    delete(CHECKER_FILES["go"]["gofmt"]["buffer"])
  endif
  if filereadable(CHECKER_FILES["go"]["gofmt"]["syntax"]) && !getfsize(CHECKER_FILES["go"]["gofmt"]["syntax"])
    delete(CHECKER_FILES["go"]["gofmt"]["syntax"])
  endif
enddef

# go vet (no exec)
def GOVetNoExec(file: string): void
  var curbufnr = winbufnr(winnr())
  var curbufname = file
  var errout: string
  var errline: number
  CHECKER_ERRORS['go']['govet'] = 0
  if &filetype != "go"
    throw "Error: (GOVetNoExec) " .. curbufname .. " is not a valid go file!"
  endif
  if !filereadable(CHECKER_FILES["go"]["govet"]["syntax"])
    # throw "Error: (GOVetNoExec) ". s:checkerfiles["go"]["govet"]["syntax"] . " is not readable!"
    return
  endif
  sign_unplace('', {'buffer': curbufnr, 'name': g:CHECKER_SIGNS_ERRORS['go']['govet']})
  errout = trim(system("grep '^vet: ' " .. CHECKER_FILES["go"]["govet"]["syntax"] .. " | cut -d ':' -f3- | head -n1"))
  # some errors are with ^filename (not ^vet)
  if empty(errout)
    errout = trim(system("grep ^" .. curbufname .. ":" .. " " .. CHECKER_FILES["go"]["govet"]["syntax"] .. " | cut -d ':' -f2- | head -n1"))
  endif
  if !empty(errout)
    CHECKER_ERRORS['go']['govet'] = 1
    errline = str2nr(split(errout, ":")[0])
    if !empty(errline)
      sign_place(errline, '', g:CHECKER_SIGNS_ERRORS['go']['govet'], curbufnr, {'lnum': errline})
    endif
  endif
enddef

# go vet async
export def GOVetAsync(file: string): void
  var curdir: string
  var dirname: string
  var newjob: job
  if !get(g:, 'checker_enabled')
    return
  endif
  # depends on checker#GoCheck()
  if CHECKER_ERRORS['go']['gofmt']
    EchoErrorMsg("Error: (GOCheck) previous function contains errors")
    EchoErrorMsg("Error: (GOVetAsync) detected error")
    return
  endif
  if &filetype == "go" && !BufferIsEmpty() && empty(JOB_QUEUE['go']['govet'])
    curdir = getcwd()
    dirname = fnamemodify(file, ":h")
    if curdir != dirname
      execute "lcd " .. dirname
    endif
    newjob = job_start(
      ['go', 'vet', file],
      {
        "out_cb": "s:OutHandlerGOVet",
        "err_cb": "s:ErrHandlerGOVet",
        "exit_cb": "s:ExitHandlerGOVet",
        "out_io": "file",
        "out_name": CHECKER_FILES["go"]["govet"]["syntax"],
        "out_msg": 0,
        "out_modifiable": 0,
        "err_io": "out"
      }
    )
    if curdir != dirname
      lcd -
    endif
    add(JOB_QUEUE['go']['govet'], job_info(newjob)['process'])
  endif
enddef

# def OutHandlerGOVet(channel: channel, message: string)
# enddef

# def ErrHandlerGOVet(channel: channel, message: string)
# enddef

def ExitHandlerGOVet(job: job, status: number)
  var file = job_info(job)["cmd"][-1]
  var idx: number
  var prevstatusline: string
  GOVetNoExec(file)
  if filereadable(CHECKER_FILES["go"]["govet"]["syntax"])
    if !getfsize(CHECKER_FILES["go"]["govet"]["syntax"])
      delete(CHECKER_FILES["go"]["govet"]["syntax"])
    endif
    # update local statusline
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['go'], "", "")
    &l:statusline = "[GO=" .. CHECKER_ERRORS['go']['gofmt'] .. "][GV=" .. CHECKER_ERRORS['go']['govet'] .. "] " .. prevstatusline
  endif
  # job command with unexpected error
  if !CHECKER_ERRORS['go']['govet'] && job_info(job)["exitval"] != 0
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE['go'], "", "")
    &l:statusline = "[GO=" .. CHECKER_ERRORS['go']['gofmt'] .. "][GV=E] " .. prevstatusline
  endif
  idx = index(JOB_QUEUE['go']['govet'], job_info(job)["process"])
  if idx >= 0
    remove(JOB_QUEUE['go']['govet'], idx)
  endif
enddef

# shows debug information
def ShowDebugInfo(signame: string, type: string)
  if type == "sh"
    if signame == g:CHECKER_SIGNS_ERRORS['sh']['sh']
      ShowErrorPopup("sh")
    elseif signame == g:CHECKER_SIGNS_ERRORS['sh']['shellcheck']
      ShowErrorPopup("shellcheck")
    else
      throw "Error: unknown sign " .. signame
    endif
  elseif type == "python"
    if signame == g:CHECKER_SIGNS_ERRORS['python']['python']
      ShowErrorPopup("python")
    elseif signame == g:CHECKER_SIGNS_ERRORS['python']['pep8']
      ShowErrorPopup("pep8")
    else
      throw "Error: unknown sign " .. signame
    endif
  elseif type == "go"
    if signame == g:CHECKER_SIGNS_ERRORS['go']['gofmt']
      ShowErrorPopup("go")
    elseif signame == g:CHECKER_SIGNS_ERRORS['go']['govet']
      ShowErrorPopup("go vet")
    else
      throw "Error: unknown sign " .. signame
    endif
  endif
enddef

# shows error popup
# TODO:
def ShowErrorPopup(type: string)
  var curline = line('.')
  var errmsg: list<string>
  if type == "sh"
    errmsg = systemlist("cut -d ':' -f2- " .. CHECKER_FILES["sh"]["sh"]["syntax"] .. " | sed 's/^ //' | head -n1")
  elseif type == "shellcheck"
    errmsg = systemlist("sed -n '/line " .. curline .. "/,/^$/p' " .. CHECKER_FILES["sh"]["shellcheck"]["syntax"] .. " | grep -v '^$' | tail -n1 | sed 's/   //g' | sed 's/  ^-- //'")
  elseif type == "python"
    errmsg = systemlist("cat " .. CHECKER_FILES["python"]["python"]["syntax"])
  elseif type == "pep8"
    errmsg = systemlist("grep -E ':" .. curline .. ":.*: ' " .. CHECKER_FILES["python"]["pep8"]["syntax"] .. " | cut -d ' ' -f2-")
  elseif type == "go"
    errmsg = systemlist("grep -F :" .. curline .. ":" .. " " .. CHECKER_FILES["go"]["gofmt"]["syntax"] .. " | cut -d ':' -f2-")
  elseif type == "go vet"
    errmsg = systemlist("grep -F :" .. curline .. ":" .. " " .. CHECKER_FILES["go"]["govet"]["syntax"])
  endif
  echo type .. ": " .. join(errmsg)
  popup_create(
    type .. ": " .. join(errmsg),
    {
      pos: 'topleft',
      line: 'cursor-3',
      col: winwidth(0) / 4,
      moved: 'any',
      border: [],
      close: 'click'
    }
  )
enddef

# shows debug information
export def SignsDebug(type: string, mode: string): void
  var curbuf = winbufnr(winnr())
  var curline = line('.')
  var curcycleline = 0
  var nextcycleline = 0
  var prevcycleline = 0
  var signameline = ""
  var signs: list<dict<any>>
  var cycleline: number
  if index(g:CHECKER_ALLOWED_TYPES, type) == -1
    EchoErrorMsg("Error: debug information for filetype '" .. type .. "' is not supported")
    return
  endif
  signs = sign_getplaced(curbuf)[0].signs
  if empty(signs)
    EchoWarningMsg("Warning: signs not found in the current buffer")
    return
  endif
  for sign in signs
    cycleline = sign.lnum
    if mode == 'cur'
      curcycleline = curline
      signameline = sign.name
      break
    elseif mode == 'next'
      if curline < cycleline
        nextcycleline = cycleline
        signameline = sign.name
        break
      endif
    elseif mode == 'prev'
      if curline > cycleline
        prevcycleline = cycleline
        signameline = sign.name
      endif
    endif
  endfor
  if curcycleline > 0 || nextcycleline > 0 || prevcycleline > 0
    if curcycleline > 0
      try
        sign_jump(curcycleline, '', curbuf)
      catch
        EchoWarningMsg("Warning: sign id not found in line " .. curcycleline)
        return
      endtry
    elseif nextcycleline > 0
      try
        sign_jump(nextcycleline, '', curbuf)
      catch
        EchoWarningMsg("Warning: sign id not found in line " .. nextcycleline)
        return
      endtry
    elseif prevcycleline > 0
      try
        sign_jump(prevcycleline, '', curbuf)
      catch
        EchoWarningMsg("Warning: sign id not found in line " .. prevcycleline)
        return
      endtry
    else
      EchoErrorMsg("Error: sign jump line not found")
      return
    endif
    if index(g:CHECKER_ALLOWED_TYPES, type) >= 0
      ShowDebugInfo(signameline, type)
    endif
  endif
enddef
