vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or checker is not enabled
if get(g:, 'autoloaded_checker') || !get(g:, 'checker_enabled')
  finish
endif
g:autoloaded_checker = true

# allowed file types
const CHECKER_ALLOWED_TYPES = ['sh', 'python', 'go']

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
# SH
execute 'sign define ' .. SIGNS_ERRORS['sh']['sh']
  .. ' text=✘ texthl=' .. (hlexists('SyntaxErrorSH') ? 'SyntaxErrorSH' : 'ErrorMsg')
execute 'sign define ' .. SIGNS_ERRORS['sh']['shellcheck']
  .. ' text=↳ texthl=' .. (hlexists('SyntaxErrorSHELLCHECK') ? 'SyntaxErrorSHELLCHECK' : 'WarningMsg')
# Python
execute 'sign define ' .. SIGNS_ERRORS['python']['python']
  .. ' text=✘ texthl=' .. (hlexists('SyntaxErrorPYTHON') ? 'SyntaxErrorPYTHON' : 'ErrorMsg')
execute 'sign define ' .. SIGNS_ERRORS['python']['pep8']
  .. ' text=↳ texthl=' .. (hlexists('SyntaxErrorPEP8') ? 'SyntaxErrorPEP8' : 'WarningMsg')
# Go
execute 'sign define ' .. SIGNS_ERRORS['go']['go']
  .. ' text=✘ texthl=' .. (hlexists('SyntaxErrorGO') ? 'SyntaxErrorGO' : 'ErrorMsg')
execute 'sign define ' .. SIGNS_ERRORS['go']['govet']
  .. ' text=↳ texthl=' .. (hlexists('SyntaxErrorGOVET') ? 'SyntaxErrorGOVET' : 'WarningMsg')

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
const TMPDIR = !empty($TMPDIR) ? ($TMPDIR == '/' ? $TMPDIR : substitute($TMPDIR, '/$', '', '')) : '/tmp'

# checker files
const PID = getpid()
const CHECKER_FILES = {
  'sh': {
    'sh': {
      'syntaxfile': $'{TMPDIR}/{$USER}-vim-checker_sh_sh_syntax-{PID}.log'
    },
    'shellcheck': {
      'syntaxfile': $'{TMPDIR}/{$USER}-vim-checker_sh_shellcheck_syntax-{PID}.log'
    }
  },
  'python': {
    'python': {
      'syntaxfile': $'{TMPDIR}/{$USER}-vim-checker_python_python_syntax-{PID}.log'
    },
    'pep8': {
      'syntaxfile': $'{TMPDIR}/{$USER}-vim-checker_python_pep8_syntax-{PID}.log'
    }
  },
  'go': {
    'go': {
      'syntaxfile': $'{TMPDIR}/{$USER}-vim-checker_go_go_syntax-{PID}.log'
    },
    'govet': {
      'syntaxfile': $'{TMPDIR}/{$USER}-vim-checker_go_govet_syntax-{PID}.log'
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
  bufdo &statusline = substitute(&statusline, REGEX_STATUSLINE_SIGNS, '', '')
enddef

# checker toggle
export def Toggle()
  if g:checker_enabled
    Disable()
  else
    Enable()
  endif
  v:statusmsg = $'checker={g:checker_enabled}'
enddef

# do checker
export def DoChecker(lang: string, tool: string, extTool: string, file: string, mode: string): void
  if !g:checker_enabled || index(CHECKER_ALLOWED_TYPES, lang) == -1
    || BufferIsEmpty() || !empty(JOB_QUEUE[lang][extTool]) || (mode == 'read' && !filereadable(file))
    return
  endif
  const tools = {
    'tool': tool,
    'exttool': extTool
  }
  Check(lang, file, tools)
  if ERRORS[lang][lang]
    EchoErrorMsg('Error: (Check) the previous function contains errors')
    EchoErrorMsg('Error: (CheckAsync) has detected an error')
  else
    CheckAsync(lang, file, tools)
  endif
enddef

# language check (no async)
export def Check(lang: string, file: string, tools: dict<string>)
  var errOut: string
  [ERRORS[lang][tools.tool], errOut] = SetLangSign(lang, tools, file)
  if !empty(errOut)
    var prevStatus = substitute(&statusline, REGEX_STATUSLINE_SIGN[lang], '', '')
    &l:statusline = ''
      .. $'[{SIGNS_TITLES[lang][tools.tool]}={ERRORS[lang][tools.tool]}]'
      .. $'[{SIGNS_TITLES[lang][tools.exttool]}=N] {prevStatus}'
    throw $'Error: {errOut}'
  endif
enddef

# language check (async)
export def CheckAsync(lang: string, file: string, tools: dict<string>): void
  var cmd: list<string>
  var cwddir  = fnamemodify(file, ':p:h')
  var synFile = CHECKER_FILES[lang][tools.exttool]['syntaxfile']
  if lang == 'sh'
    cmd = ['shellcheck', '--color=never', '-']
  elseif lang == 'python'
    # pep8 has been renamed to pycodestyle
    cmd = executable('pycodestyle') ? ['pycodestyle', '-'] : ['pep8', '-']
  elseif lang == 'go'
    # no stdin
    cmd = ['go', 'vet', '.']
  endif
  if &filetype == lang && !BufferIsEmpty() && empty(JOB_QUEUE[lang][tools.exttool])
    var cbvars = {
      'lang': lang,
      'tool': tools.tool,
      'exttool': tools.exttool,
      'file': file,
      'syntaxfile': synFile
    }
    var opts = {
      'out_cb': function(OutHandler),
      'err_cb': function(ErrHandler),
      'exit_cb': function(ExitHandler, [cbvars]),
      'out_io': 'file',
      'out_name': synFile,
      'out_msg': 0,
      'out_modifiable': 0,
      'err_io': 'out',
      'cwd': cwddir
    }
    # stdin (sh, python)
    if index(['sh', 'python'], lang) != -1
      opts.in_io = 'buffer'
      opts.in_buf = bufnr(file)
    endif
    var newjob = job_start(cmd, opts)
    add(JOB_QUEUE[lang][tools.exttool], job_info(newjob)['process'])
  endif
enddef

# set language sign (lang tool)
def SetLangSign(lang: string, tools: dict<string>, file: string): list<any>
  var signErrTool = SIGNS_ERRORS[lang][tools.tool]
  var signErrExtTool = SIGNS_ERRORS[lang][tools.exttool]
  var synFile = CHECKER_FILES[lang][tools.tool]["syntaxfile"]
  sign_unplace('', {'buffer': file, 'name': signErrTool})
  sign_unplace('', {'buffer': file, 'name': signErrExtTool})
  var numErrs = 0
  var cmd: string
  if lang == 'sh'
    var theShell = getline(1) =~ 'bash' ? 'bash' : 'sh'
    if theShell == 'sh'
      cmd = $'sh -n 2>&1'
    elseif theShell == 'bash'
      cmd = 'bash --noprofile --norc -n 2>&1'
    endif
  elseif lang == 'python'
    cmd = $'python3 -c {shellescape('import ast,sys; ast.parse(sys.stdin.read(), filename="<buffer>")')} 2>&1'
  elseif lang == 'go'
    cmd = 'gofmt -e 2>&1'
  endif
  var errOut: string
  var bufFile = join(getline(1, '$'), "\n") .. (&l:eol ? "\n" : '')
  var cmdOut = system(cmd, bufFile)
  if !empty(cmdOut)
    writefile(split(cmdOut, "\n"), synFile)
  endif
  if v:shell_error != 0
    numErrs = 1
    errOut = cmdOut
    var errLine: number
    if lang == 'sh'
      errLine = str2nr(split(split(errOut, ':')[1])[-1])
      if errLine > line('$')
        errLine = line('$')
      endif
    elseif lang == 'python'
      errLine = str2nr(trim(split(errOut)[-1], ')', 2))
    elseif lang == 'go'
      errLine = str2nr(split(errOut, ':')[1])
    endif
    if !empty(errLine)
      sign_place(errLine, '', signErrTool, file, {'lnum': errLine})
      cursor(errLine, 1)
    endif
  endif
  if filereadable(synFile) && (!getfsize(synFile) || !numErrs)
    delete(synFile)
  endif
  return [numErrs, errOut]
enddef

# set tool signs (async tool)
def SetToolSigns(lang: string, extTool: string, file: string): list<any>
  var lineErrs: list<string>
  var errLine: number
  var synFile = CHECKER_FILES[lang][extTool]['syntaxfile']
  var signErr = SIGNS_ERRORS[lang][extTool]
  sign_unplace('', {'buffer': file, 'name': signErr})
  var numErrs = 0
  for line in readfile(synFile)
    if lang == 'sh'
      if extTool == 'shellcheck' && line =~ '^In '
        errLine = str2nr(trim(split(line)[-1], ':', 2))
        add(lineErrs, line)
        ++numErrs
      endif
    elseif lang == 'python'
      if extTool == 'pep8' && line =~ $'^stdin:'
        errLine = str2nr(split(line, ':')[1])
        add(lineErrs, line)
        ++numErrs
      endif
    elseif lang == 'go'
      if extTool == 'govet' && line =~ $'^./{fnamemodify(file, ':t')}:'
        errLine = str2nr(split(line, ':')[1])
        add(lineErrs, line)
        ++numErrs
      endif
    endif
    if !empty(errLine) && type(errLine) == v:t_number
      sign_place(errLine, '', signErr, file, {'lnum': errLine})
    endif
  endfor
  return [numErrs, lineErrs]
enddef

# out handler
def OutHandler(channel: channel, message: string)
enddef

# error handler
def ErrHandler(channel: channel, message: string)
enddef

# exit handler
def ExitHandler(vars: dict<string>, job: job, status: number)
  var errOut: list<string>
  var errExit = false
  var fileWinID = bufwinid(vars.file)
  var selWinID = win_getid()
  # TODO: without win_gotoid()
  if selWinID != fileWinID
    win_gotoid(fileWinID)
  endif
  [ERRORS[vars.lang][vars.exttool], errOut] = SetToolSigns(vars.lang, vars.exttool, vars.file)
  # job command with unexpected error
  if !ERRORS[vars.lang][vars.exttool] && job_info(job)['exitval'] != 0
    # govet also detects errors in other files (go vet '.')
    if vars.exttool == 'govet'
      var errMsg = filereadable(vars.syntaxfile) ? join(readfile(vars.syntaxfile), "\n") : ''
      if errMsg =~ '\v^(go:|vet:|panic:)'
        errExit = true
      endif
    else
      errExit = true
    endif
  endif
  var prevStatus = substitute(&statusline, REGEX_STATUSLINE_SIGN[vars.lang], '', '')
  &l:statusline = ''
    .. $'[{SIGNS_TITLES[vars.lang][vars.tool]}={ERRORS[vars.lang][vars.tool]}]'
    .. $'[{SIGNS_TITLES[vars.lang][vars.exttool]}=' .. (errExit ? 'E' : ERRORS[vars.lang][vars.exttool]) .. '] ' .. prevStatus
  var idx = index(JOB_QUEUE[vars.lang][vars.exttool], job_info(job)['process'])
  if idx >= 0
    remove(JOB_QUEUE[vars.lang][vars.exttool], idx)
  endif
  if filereadable(vars.syntaxfile) && (!getfsize(vars.syntaxfile) || !ERRORS[vars.lang][vars.exttool])
    delete(vars.syntaxfile)
  endif
  if selWinID != fileWinID
    win_gotoid(selWinID)
  endif
enddef

# shows the signs debug information
export def SignsDebug(lang: string, tool: string, extTool: string, kind: string): void
  var curBuf = winbufnr(winnr())
  var curLine = line('.')
  var cycle: number
  var curCycle: number
  var nextCycle: number
  var prevCycle: number
  var signID: number
  var signName: string
  if index(CHECKER_ALLOWED_TYPES, lang) == -1
    EchoErrorMsg($"Error: debug information for the filetype '{lang}' is not supported")
    return
  endif
  var signs = sign_getplaced(curBuf)[0].signs
  if empty(signs)
    EchoWarningMsg('Warning: signs were not found in the current buffer')
    return
  endif
  for sign in signs
    cycle = sign.lnum
    signName = sign.name
    if kind == 'cur'
      curCycle = curLine
      break
    elseif kind == 'next' && curLine < cycle
      nextCycle = cycle
      break
    elseif kind == 'prev' && curLine > cycle
      prevCycle = cycle
    endif
  endfor
  if curCycle > 0
    signID = curCycle
  elseif nextCycle > 0
    signID = nextCycle
  elseif prevCycle > 0
    signID = prevCycle
  elseif !empty(signs)
    signID = signs[0]['id']
  else
    EchoWarningMsg('Warning: sign id line was not found')
    return
  endif
  try
    sign_jump(signID, '', curBuf)
    var errOut = ShowDebugInfo(lang, tool, extTool, signName)
    if !empty(errOut)
      EchoErrorMsg(errOut)
    endif
  catch
    EchoWarningMsg($"Warning: sign id was not found in the line '{signID}'")
  endtry
enddef

# shows the debug information
def ShowDebugInfo(lang: string, tool: string, extTool: string, sign: string): string
  var errMsg: string
  if sign == SIGNS_ERRORS[lang][tool]
    ShowError(lang, tool)
  elseif sign == SIGNS_ERRORS[lang][extTool]
    ShowError(lang, extTool)
  else
    errMsg = $'Error: unknown sign {sign}'
  endif
  return errMsg
enddef

# shows the error via echo or popup
def ShowError(lang: string, tool: string)
  var errMsg: string
  errMsg = GetErrorLine(lang, tool)
  var text = $'[{SIGNS_TITLES[lang][tool]}]: {errMsg}'
  if !empty(errMsg)
    if g:checker_showpopup
      popup_create(
        text, {
        pos: 'topleft',
        line: 'cursor+1',
        # col: winwidth(0) / 4,
        col: 'cursor+9',
        moved: 'any',
        border: [1, 1, 1, 1],
        padding: [0, 1, 0, 1],
        # borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        close: 'click'
      })
    else
      echo text
    endif
  else
    EchoWarningMsg('Warning: error was not found')
  endif
enddef

# gets the current error line
def GetErrorLine(lang: string, tool: string): string
  var errMsg: string
  var idx: number
  var curLine = line('.')
  var errOut = readfile(CHECKER_FILES[lang][tool]['syntaxfile'])
  if lang == 'sh'
    if tool == 'sh'
      # sh sometimes uses line + 1, bash only line
      idx = match(errOut, $'^[^:]*:[^:]* \({curLine}\|{curLine + 1}\): ')
      if idx >= 0
        errMsg = errOut[idx]
      endif
    elseif tool == 'shellcheck'
      idx = match(errOut, $'^In .* line {curLine}:$')
      if idx >= 0
        errMsg = $'{errOut[idx]} {errOut[idx + 1]} {errOut[idx + 2]}'
      endif
    endif
  elseif lang == 'python'
    if tool == 'python'
      idx = match(errOut, $'^  File .*, line {curLine}$')
      if idx >= 0
        errMsg = errOut[len(errOut) - 1]
      endif
    elseif tool == 'pep8'
      idx = match(errOut, $'^[^:]*:{curLine}:[^:]*: E')
      if idx >= 0
        errMsg = errOut[idx]
      endif
    endif
  elseif lang == 'go'
    if tool == 'go'
      idx = match(errOut, $'^[^:]*:{curLine}:[^:]*: ')
      if idx >= 0
        errMsg = errOut[idx]
      endif
    elseif tool == 'govet'
      var file = fnamemodify(bufname('%'), ':t')
      idx = match(errOut, $'^./{file}:{curLine}:[^:]*: ')
      if idx >= 0
        errMsg = errOut[idx]
      endif
    endif
  endif
  return errMsg
enddef
