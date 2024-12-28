vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_runprg') || !get(g:, 'runprg_enabled')
  finish
endif
g:autoloaded_runprg = true

# script local variables
const BUFFER_NAME = $"runprg_{strcharpart(sha256('runprg'), 0, 8)}"

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

# close
export def Close()
  var runwinid = GetRunBufWinId()
  if runwinid > 0
    win_execute(runwinid, "bw")
  endif
enddef

# run
export def Run(cmd: string, file: string): void
  if empty(cmd) || !executable(split(cmd)[0])
    EchoErrorMsg($"Error: the cmd '{cmd}' is not executable")
    return
  endif
  echo !empty(file) ? system($"{cmd} {file}") : system(cmd)
  if v:shell_error != 0
    EchoErrorMsg($"Error: exit code {v:shell_error}")
  endif
enddef

# run setup window
def RunSetupWindow(lines: list<string>, position: string)
  Close()
  if bufexists(BUFFER_NAME) && getbufinfo(BUFFER_NAME)[0].hidden
    if position == "below"
      execute $"rightbelow split {BUFFER_NAME}"
    elseif position == "above"
      execute $"leftabove split {BUFFER_NAME}"
    endif
  else
    if position == "below"
      below new
    elseif position == "above"
      aboveleft new
    endif
    silent execute $"file {BUFFER_NAME}"
  endif
  silent deletebufline(BUFFER_NAME, 1, '$')
  appendbufline(BUFFER_NAME, 0, lines)
  deletebufline(BUFFER_NAME, '$')
  setlocal filetype=runprg
enddef

# run with window
export def RunWindow(cmd: string, file: string, position: string, gowin: bool): void
  var outmsg: list<string>
  var runwinid = GetRunBufWinId()
  var selwinid = win_getid()
  if selwinid == runwinid
    EchoWarningMsg($"Warning: already using the same window '{BUFFER_NAME}'")
    return
  endif
  if empty(cmd) || !executable(split(cmd)[0])
    EchoErrorMsg($"Error: the command '{cmd}' is not executable")
    return
  endif
  if index(['below', 'above'], position) == -1
    EchoErrorMsg($"Error: the position '{position}' is not allowed")
    return
  endif
  outmsg = !empty(file) ? systemlist($"{cmd} {file}") : systemlist(cmd)
  if v:shell_error != 0
    EchoErrorMsg($"Error: exit code {v:shell_error}")
  endif
  if empty(outmsg)
    EchoWarningMsg("Warning: empty output")
    return
  endif
  RunSetupWindow(outmsg, position)
  &l:statusline = $"[runprg]: {cmd} {!empty(file) ? fnamemodify(file, ':~') : ''} {&l:statusline}"
  runwinid = GetRunBufWinId()
  win_execute(runwinid, "cursor(1, 1)")
  win_execute(runwinid, $"resize {len(outmsg)}")
  win_gotoid(gowin ? runwinid : selwinid)
enddef
