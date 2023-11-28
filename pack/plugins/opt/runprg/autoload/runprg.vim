vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_runprg') || !get(g:, 'runprg_enabled')
  finish
endif
g:autoloaded_runprg = true

# script local variables
const BUFFER_NAME = "runprg_" .. strftime('%Y%m%d%H%M%S', localtime())

# allowed file types
const ALLOWED_TYPES = ["sh", "python", "go"]

# run commands
const COMMANDS = {
  'sh': {
    'command': join(g:runprg_sh_command)
  },
  'bash': {
    'command': join(g:runprg_bash_command)
  },
  'python': {
    'command': join(g:runprg_python_command)
  },
  'go': {
    'command': join(g:runprg_go_command)
  }
}

# prints the error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
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

# gets Run buffer window id
def GetRunBufWinId(): number
  return bufexists(BUFFER_NAME) ? bufwinid(BUFFER_NAME) : -1
enddef

# detects if the shell is sh or bash using shebang
def SHShellType(lang: string): string
  if lang != "sh"
    EchoErrorMsg($"Error: lang '{lang}' is not supported")
    return ''
  endif
  return getline(1) =~ "bash" ? "bash" : "sh"
enddef

# close
export def Close()
  var runwinid = GetRunBufWinId()
  if runwinid > 0
    win_execute(runwinid, "bw")
  endif
enddef

# run
export def Run(lang: string, file: string): void
  var cmd: string
  var theshell: string
  if index(ALLOWED_TYPES, lang) == -1
    EchoErrorMsg($"Error: running lang '{lang}' is not supported")
    return
  endif
  if lang == "sh"
    theshell = SHShellType(lang)
    cmd = COMMANDS[theshell]["command"]
  else
    cmd = COMMANDS[lang]["command"]
  endif
  echo system($"{cmd} {file}")
  if v:shell_error != 0
    EchoErrorMsg($"Error: exit code {v:shell_error}")
  endif
enddef

# run setup window
def RunSetupWindow()
  var bid = GetRunBufWinId()
  if bid > 0
    win_gotoid(bid)
  elseif bufexists(BUFFER_NAME) && getbufinfo(BUFFER_NAME)[0].hidden
    execute $"rightbelow split {BUFFER_NAME}"
  else
    below new
    setlocal winfixheight
    setlocal winfixwidth
    setlocal buftype=nowrite
    setlocal noswapfile
    setlocal buflisted
    silent execute $"file {BUFFER_NAME}"
  endif
enddef

# run with window
export def RunWindow(lang: string, file: string): void
  var cmd: string
  var theshell: string
  var outmsg: list<string>
  var runwinid = GetRunBufWinId()
  var selwinid = win_getid()
  if selwinid == runwinid
    EchoWarningMsg($"Warning: already using the same window {BUFFER_NAME}")
    return
  endif
  if index(ALLOWED_TYPES, lang) == -1
    EchoErrorMsg($"Error: running lang '{lang}' is not supported")
    return
  endif
  if lang == "sh"
    theshell = SHShellType(lang)
    cmd = COMMANDS[theshell]["command"]
  else
    cmd = COMMANDS[lang]["command"]
  endif
  outmsg = systemlist($"{cmd} {file}")
  if v:shell_error != 0
    EchoErrorMsg($"Error: exit code {v:shell_error}")
  endif
  if empty(outmsg)
    EchoWarningMsg("Warning: empty output")
    return
  endif
  RunSetupWindow()
  runwinid = GetRunBufWinId()
  appendbufline(BUFFER_NAME, 0, outmsg)
  deletebufline(BUFFER_NAME, '$')
  win_execute(runwinid, "cursor(1, 1)")
  win_execute(runwinid, $"resize {len(outmsg)}")
  win_gotoid(selwinid)
enddef
