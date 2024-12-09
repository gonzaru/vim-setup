vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or checker is not enabled
if get(g:, 'autoloaded_checker') || !get(g:, 'checker_enabled')
  finish
endif
g:autoloaded_checker = true

# allowed file types
const CHECKER_ALLOWED_TYPES = ["sh", "python", "go"]

# script local callback vars (ExitHandlerCheck)
final CALLBACK_VARS = {
  'lang': "",
  'tool': "",
  'extool': "",
  'file': "",
  'syntaxfile': ""
}

# signs titles
const SIGNS_TITLES = {
  'sh': {
    'sh': 'SH',
    'shellcheck': 'SC'
  },
  'python': {
    'python': 'PY',
    'pep8': 'P8'
  },
  'go': {
    'go': 'GO',
    'govet': 'GV'
  }
}

# signs errors
const SIGNS_ERRORS = {
  'sh': {
    'sh': 'checker_sh',
    'shellcheck': 'checker_shellcheck'
  },
  'python': {
    'python': 'checker_python',
    'pep8': 'checker_pep8'
  },
  'go': {
    'go': 'checker_go',
    'govet': 'checker_govet'
  }
}

# create signs
if has('signs')
  # SH
  execute "sign define " .. SIGNS_ERRORS['sh']['sh']
    .. " text=✘ texthl=" .. (hlexists('SyntaxErrorSH') ? 'SyntaxErrorSH' : 'ErrorMsg')
  execute "sign define " .. SIGNS_ERRORS['sh']['shellcheck']
    .. " text=↳ texthl=" .. (hlexists('SyntaxErrorSHELLCHECK') ? 'SyntaxErrorSHELLCHECK' : 'WarningMsg')
  # Python
  execute "sign define " .. SIGNS_ERRORS['python']['python']
    .. " text=✘ texthl=" .. (hlexists('SyntaxErrorPYTHON') ? 'SyntaxErrorPYTHON' : 'ErrorMsg')
  execute "sign define " .. SIGNS_ERRORS['python']['pep8']
    .. " text=↳ texthl=" .. (hlexists('SyntaxErrorPEP8') ? 'SyntaxErrorPEP8' : 'WarningMsg')
  # Go
  execute "sign define " .. SIGNS_ERRORS['go']['go']
    .. " text=✘ texthl=" .. (hlexists('SyntaxErrorGO') ? 'SyntaxErrorGO' : 'ErrorMsg')
  execute "sign define " .. SIGNS_ERRORS['go']['govet']
    .. " text=↳ texthl=" .. (hlexists('SyntaxErrorGOVET') ? 'SyntaxErrorGOVET' : 'WarningMsg')
endif

# checker errors
final ERRORS = {
  'sh': {
    'sh': 0,
    'shellcheck': 0
  },
  'python': {
    'python': 0,
    'pep8': 0
  },
  'go': {
    'go': 0,
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

# statusline regex sign
const REGEX_STATUSLINE_SIGN = {
  'sh': '^\[' .. SIGNS_TITLES['sh']['sh'] .. '=\d*\]\[' .. SIGNS_TITLES['sh']['shellcheck'] .. '=\d*N\?E\?\] ',
  'python': '^\[' .. SIGNS_TITLES['python']['python'] .. '=\d*\]\[' .. SIGNS_TITLES['python']['pep8'] .. '=\d*N\?E\?\] ',
  'go': '^\[' .. SIGNS_TITLES['go']['go'] .. '=\d*\]\[' .. SIGNS_TITLES['go']['govet'] .. '=\d*N\?E\?\] '
}

# statusline regex signs
const REGEX_STATUSLINE_SIGNS = '^\[..=\d*\]\[..=\d*N\?E\?\] '

# user tmp directory
const TMPDIR = !empty($TMPDIR) ? ($TMPDIR == "/" ? $TMPDIR : substitute($TMPDIR, "/$", "", "")) : "/tmp"

# checker files
const pid = getpid()
const FILES = {
  'sh': {
    'sh': {
      'buffer': $"{TMPDIR}/{$USER}-vim-checker_sh_sh_buffer-{pid}.log",
      'syntaxfile': $"{TMPDIR}/{$USER}-vim-checker_sh_sh_syntax-{pid}.log"
    },
    'shellcheck': {
      'buffer': $"{TMPDIR}/{$USER}-vim-checker_sh_shellcheck_buffer-{pid}.log",
      'syntaxfile': $"{TMPDIR}/{$USER}-vim-checker_sh_shellcheck_syntax-{pid}.log"
    }
  },
  'python': {
    'python': {
      'buffer': $"{TMPDIR}/{$USER}-vim-checker_python_python_buffer-{pid}.log",
      'syntaxfile': $"{TMPDIR}/{$USER}-vim-checker_python_python_syntax-{pid}.log"
    },
    'pep8': {
      'buffer': $"{TMPDIR}/{$USER}-vim-checker_python_pep8_buffer-{pid}.log",
      'syntaxfile': $"{TMPDIR}/{$USER}-vim-checker_python_pep8_syntax-{pid}.log"
    }
  },
  'go': {
    'go': {
      'buffer': $"{TMPDIR}/{$USER}-vim-checker_go_go_buffer-{pid}.log",
      'syntaxfile': $"{TMPDIR}/{$USER}-vim-checker_go_go_syntax-{pid}.log"
    },
    'govet': {
      'buffer': $"{TMPDIR}/{$USER}-vim-checker_go_govet_buffer-{pid}.log",
      'syntaxfile': $"{TMPDIR}/{$USER}-vim-checker_go_govet_syntax-{pid}.log"
    }
  }
}

# prints the error message and saves the message in the message-history
export def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# prints the warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom msg
    echohl None
  endif
enddef

# tells if the buffer is empty
def BufferIsEmpty(): bool
  return line('$') == 1 && empty(getline(1))
enddef

# checker enable
export def Enable()
  g:checker_enabled = true
  doautocmd BufWinEnter
enddef

# checker disable
export def Disable()
  g:checker_enabled = false
  for b in getbufinfo({'buflisted': 1})
    for s in sign_getplaced(b.bufnr)[0].signs
      for f in CHECKER_ALLOWED_TYPES
        for [_, v] in items(SIGNS_ERRORS[f])
          if v == s.name
            sign_unplace('', {'buffer': b.bufnr, 'id': s.id, 'name': s.name})
          endif
        endfor
      endfor
    endfor
  endfor
  bufdo &statusline = substitute(&statusline, REGEX_STATUSLINE_SIGNS, "", "")
enddef

# checker toggle
export def Toggle()
  if g:checker_enabled
    Disable()
  else
    Enable()
  endif
  v:statusmsg = $"checker={g:checker_enabled}"
enddef

# do checker
export def DoChecker(lang: string, tool: string, exttool: string, file: string, mode: string): void
  if !g:checker_enabled || index(CHECKER_ALLOWED_TYPES, lang) == -1
    || BufferIsEmpty() || !empty(JOB_QUEUE[lang][exttool]) || (mode == 'read' && !filereadable(file))
    return
  endif
  Check(lang, tool, exttool, file, mode)
  if ERRORS[lang][lang]
    EchoErrorMsg("Error: (Check) the previous function contains errors")
    EchoErrorMsg("Error: (CheckAsync) has detected an error")
  else
    CheckAsync(lang, tool, exttool, file)
  endif
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

# lang check
export def Check(lang: string, tool: string, exttool: string, curbuf: string, mode: string): void
  var errout: string
  var prevstatusline: string
  [ERRORS[lang][tool], errout] = SetLangSign(lang, tool, exttool, curbuf, mode)
  if !empty(errout)
    prevstatusline = substitute(&statusline, REGEX_STATUSLINE_SIGN[lang], "", "")
    &l:statusline = ""
      .. $"[{SIGNS_TITLES[lang][tool]}={ERRORS[lang][tool]}]"
      .. $"[{SIGNS_TITLES[lang][exttool]}=N] {prevstatusline}"
    throw $"Error: ({mode}) {errout}"
  elseif mode == "write"
    # for autocmd BufWriteCmd (see v:event)
    noautocmd write
  endif
enddef

# set lang sign (lang tool)
def SetLangSign(lang: string, tool: string, exttool: string, curbuf: string, mode: string): list<any>
  var errline: number
  var nerrors: number
  var errout: string
  var theshell: string
  var buffile = FILES[lang][tool]["buffer"]
  var syntaxfile = FILES[lang][tool]["syntaxfile"]
  var signerror1 = SIGNS_ERRORS[lang][tool]
  var signerror2 = SIGNS_ERRORS[lang][exttool]
  sign_unplace('', {'buffer': curbuf, 'name': signerror1})
  sign_unplace('', {'buffer': curbuf, 'name': signerror2})
  nerrors = 0
  if mode == "read"
    buffile = curbuf
  elseif mode == "write"
    silent execute $"noautocmd write! {buffile}"
  endif
  if lang == "sh"
    theshell = getline(1) =~ "bash" ? "bash" : "sh"
    if theshell == "sh"
      system($"sh -n {buffile} > {syntaxfile} 2>&1")
    elseif theshell == "bash"
      system($"bash --norc -n {buffile} > {syntaxfile} 2>&1")
    endif
  elseif lang == "python"
    system("python3 -c \"import ast; ast.parse(open('" .. buffile .. "').read())\" > " .. syntaxfile .. " 2>&1")
  elseif lang == "go"
    # send to stderr, goftm puts all output file in stdout
    system($"gofmt -e {buffile} 2> {syntaxfile}")
  endif
  if v:shell_error != 0
    nerrors = 1
    errout = join(readfile(syntaxfile))
    if lang == "sh"
      errline = str2nr(split(split(errout, ":")[1], " ")[-1])
      if errline > line('$')
        errline = line('$')
      endif
    elseif lang == "python"
      errline = str2nr(trim(split(errout, " ")[-1], ')', 2))
    elseif lang == "go"
      errline = str2nr(split(errout, ":")[1])
    endif
    if !empty(errline)
      sign_place(errline, '', signerror1, curbuf, {'lnum': errline})
      cursor(errline, 1)
    endif
  endif
  if filereadable(syntaxfile) && !getfsize(syntaxfile)
    delete(syntaxfile)
  endif
  if mode == "write" && filereadable(buffile)
    delete(buffile)
  endif
  return [nerrors, errout]
enddef

# set tool signs (async tool)
def SetToolSigns(lang: string, exttool: string, curbuf: string): list<any>
  var nerrors: number
  var lerrors: list<string>
  var errline: number
  var errout: string
  var syntaxfile = FILES[lang][exttool]["syntaxfile"]
  var signerror = SIGNS_ERRORS[lang][exttool]
  sign_unplace('', {'buffer': curbuf, 'name': signerror})
  nerrors = 0
  for line in readfile(syntaxfile)
    if lang == "sh" && exttool == "shellcheck" && line =~ "^In "
      errline = str2nr(split(split(line, " ")[3], ":")[0])
      add(lerrors, line)
      ++nerrors
    elseif lang == "python" && exttool == "pep8" && line =~ $"^{curbuf}:"
      errline = str2nr(split(line, ":")[1])
      add(lerrors, line)
      ++nerrors
    elseif lang == "go" && exttool == "govet" && line !~ "^#"
      errline = str2nr(split(line, ":")[1])
      add(lerrors, line)
      ++nerrors
    endif
    if !empty(errline) && type(errline) == v:t_number
      sign_place(errline, '', signerror, curbuf, {'lnum': errline})
    endif
  endfor
  return [nerrors, lerrors]
enddef

# lang check (async)
export def CheckAsync(lang: string, tool: string, exttool: string, file: string): void
  var cmd: list<string>
  var newjob: job
  var syntaxfile = FILES[lang][exttool]["syntaxfile"]
  if lang == "sh"
    cmd = ['shellcheck', '--color=never', file]
  elseif lang == "python"
    cmd = ['pep8', file]
  elseif lang == "go"
    cmd = ['go', 'vet', file]
  endif
  if &filetype == lang && !BufferIsEmpty() && empty(JOB_QUEUE[lang][exttool])
    CALLBACK_VARS['lang'] = lang
    CALLBACK_VARS['tool'] = tool
    CALLBACK_VARS['exttool'] = exttool
    CALLBACK_VARS['file'] = file
    CALLBACK_VARS['syntaxfile'] = syntaxfile
    newjob = job_start(
      cmd,
      {
        "out_cb": "s:OutHandlerCheck",
        "err_cb": "s:ErrHandlerCheck",
        "exit_cb": "s:ExitHandlerCheck",
        "out_io": "file",
        "out_name": syntaxfile,
        "out_msg": 0,
        "out_modifiable": 0,
        "err_io": "out"
      }
    )
    add(JOB_QUEUE[lang][exttool], job_info(newjob)['process'])
  endif
enddef

# out handler
def OutHandlerCheck(channel: channel, message: string)
enddef

# err handler
def ErrHandlerCheck(channel: channel, message: string)
enddef

# exit handler
def ExitHandlerCheck(job: job, status: number)
  var idx: number
  var errout: list<string>
  var errexit = false
  var prevstatusline: string
  var lang = CALLBACK_VARS['lang']
  var tool = CALLBACK_VARS['tool']
  var exttool = CALLBACK_VARS['exttool']
  var file = CALLBACK_VARS['file']
  var syntaxfile = CALLBACK_VARS['syntaxfile']
  var filewinid = bufwinid(file)
  var selwinid = win_getid()
  # TODO: without win_gotoid()
  if selwinid != filewinid
    win_gotoid(filewinid)
  endif
  [ERRORS[lang][exttool], errout] = SetToolSigns(lang, exttool, file)
  # job command with unexpected error
  if !ERRORS[lang][exttool] && job_info(job)["exitval"] != 0
    errexit = true
  endif
  prevstatusline = substitute(&statusline, REGEX_STATUSLINE_SIGN[lang], "", "")
  &l:statusline = ""
    .. $"[{SIGNS_TITLES[lang][tool]}={ERRORS[lang][tool]}]"
    .. $"[{SIGNS_TITLES[lang][exttool]}=" .. (errexit ? "E" : ERRORS[lang][exttool]) .. "] " .. prevstatusline
  idx = index(JOB_QUEUE[lang][exttool], job_info(job)["process"])
  if idx >= 0
    remove(JOB_QUEUE[lang][exttool], idx)
  endif
  if filereadable(syntaxfile) && !getfsize(syntaxfile)
    delete(syntaxfile)
  endif
  if selwinid != filewinid
    win_gotoid(selwinid)
  endif
enddef

# shows the signs debug information
export def SignsDebug(lang: string, tool: string, exttool: string, mode: string): void
  var errout: string
  var curbuf = winbufnr(winnr())
  var curline = line('.')
  var curcycleline = 0
  var nextcycleline = 0
  var prevcycleline = 0
  var signidline: number
  var signameline: string
  var signs: list<dict<any>>
  var cycleline: number
  if index(CHECKER_ALLOWED_TYPES, lang) == -1
    EchoErrorMsg($"Error: debug information for the filetype '{lang}' is not supported")
    return
  endif
  signs = sign_getplaced(curbuf)[0].signs
  if empty(signs)
    EchoWarningMsg("Warning: signs were not found in the current buffer")
    return
  endif
  for sign in signs
    cycleline = sign.lnum
    signameline = sign.name
    if mode == 'cur'
      curcycleline = curline
      break
    elseif mode == 'next' && curline < cycleline
      nextcycleline = cycleline
      break
    elseif mode == 'prev' && curline > cycleline
      prevcycleline = cycleline
    endif
  endfor
  if curcycleline > 0
    signidline = curcycleline
  elseif nextcycleline > 0
    signidline = nextcycleline
  elseif prevcycleline > 0
    signidline = prevcycleline
  elseif !empty(signs)
    signidline = signs[0]['id']
  else
    EchoWarningMsg("Warning: sign id line was not found")
    return
  endif
  try
    sign_jump(signidline, '', curbuf)
    errout = ShowDebugInfo(lang, tool, exttool, signameline)
    if !empty(errout)
      EchoErrorMsg(errout)
    endif
  catch
    EchoWarningMsg($"Warning: sign id was not found in the line '{signidline}'")
  endtry
enddef

# shows the debug information
def ShowDebugInfo(lang: string, tool: string, exttool: string, sign: string): string
  var error: string
  if sign == SIGNS_ERRORS[lang][tool]
    ShowErrorPopup(lang, tool)
  elseif sign == SIGNS_ERRORS[lang][exttool]
    ShowErrorPopup(lang, exttool)
  else
    error = $"Error: unknown sign {sign}"
  endif
  return error
enddef

# shows the error popup
def ShowErrorPopup(lang: string, tool: string)
  var errmsg: string
  errmsg = GetErrorLine(lang, tool)
  if !empty(errmsg)
    echo $"{tool}: {errmsg}"
    if g:checker_showpopup
      popup_create(
        $"{tool}: {errmsg}",
        {
          pos: 'topleft',
          line: 'cursor-3',
          col: winwidth(0) / 4,
          moved: 'any',
          border: [],
          close: 'click'
        }
      )
    endif
  else
    EchoWarningMsg("Warning: error popup was not found")
  endif
enddef

# gets the current error line
def GetErrorLine(lang: string, tool: string): string
  var errmsg: string
  var idx: number
  var curline = line('.')
  var errout = readfile(FILES[lang][tool]["syntaxfile"])
  if lang == "sh"
    if tool == "sh"
      idx = match(errout, "^.*: " .. curline .. ": ")
      if idx >= 0
        errmsg = "line " .. trim(join(split(errout[idx], ":")[1 : ], ":"))
      endif
    elseif tool == "shellcheck"
      idx = match(errout, "^In .* line " .. curline .. ":$")
      if idx >= 0
        errmsg = "line " .. split(errout[idx], " ")[-1] .. " " .. substitute(errout[idx + 2], '^.*\^-- ', "", "")
      endif
    endif
  elseif lang == "python"
    if tool == "python"
      idx = match(errout, '^  File .*, line ' .. curline .. '$')
      if idx >= 0
        errmsg = "line " .. split(trim(errout[idx]), " ")[-1] .. ": " .. trim(join(errout[idx + 3 : ]))
      endif
    elseif tool == "pep8"
      idx = match(errout, '^.*:' .. curline .. ":.*: E")
      if idx >= 0
        errmsg = "line " .. split(errout[idx], ":")[1] .. ": " .. trim(join(split(errout[idx], ":")[3 : ]))
      endif
    endif
  elseif lang == "go"
    if tool == "go"
      idx = match(errout, '^.*:' .. curline .. ":.*: ")
      if idx >= 0
        errmsg = "line " .. split(errout[idx], ":")[1] .. ": " .. trim(join(split(errout[idx], ":")[3 : ]))
      endif
    elseif tool == "govet"
      idx = match(errout, '.*:' .. curline .. ":.*: ")
      if idx >= 0
        errmsg = "line " .. split(errout[idx], ":")[1]  .. ": " .. trim(join(split(errout[idx], ":")[3 : ]))
      endif
    endif
  endif
  return errmsg
enddef
