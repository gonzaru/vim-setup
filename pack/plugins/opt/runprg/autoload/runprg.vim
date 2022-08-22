vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_runprg') || !get(g:, 'runprg_enabled') || &cp
  finish
endif
g:autoloaded_runprg = 1

# script local variables
const RUNPRG_BUFFER_NAME = "runprg_" .. strftime('%Y%m%d%H%M%S', localtime())

# allowed file types
const RUNPRG_ALLOWED_TYPES = ["sh", "python", "go"]

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

# gets Run buffer window id
def GetRunBufWinId(): number
  return bufexists(RUNPRG_BUFFER_NAME) ? bufwinid(RUNPRG_BUFFER_NAME) : -1
enddef

# detects if the shell is sh or bash using shebang
def SHShellType(): string
  if &filetype != "sh"
    EchoErrorMsg("Error: filetype '" .. &filetype .. "' is not supported")
    return ''
  endif
  return getline(1) =~ "bash$" ? "bash" : "sh"
enddef

# close
export def Close()
  var runwinid = GetRunBufWinId()
  if runwinid > 0
    win_execute(runwinid, "close")
  endif
enddef

# run
export def Run(file: string): void
  if index(RUNPRG_ALLOWED_TYPES, &filetype) == -1
    EchoErrorMsg("Error: running filetype '" .. &filetype .. "' is not supported")
    return
  endif
  if &filetype == "sh"
    echo system(SHShellType() .. " " .. file)
  elseif &filetype == "python"
    echo system("python3 " .. file)
  elseif &filetype == "go"
    echo system("go run " .. file)
  endif
  if v:shell_error != 0
    EchoErrorMsg("Error: exit code " .. v:shell_error)
  endif
enddef

# run using a window
export def RunWindow(file: string): void
  var selwinid = win_getid()
  var runwinid = GetRunBufWinId()
  var outmsg: list<string>
  if selwinid == runwinid
    EchoWarningMsg("Warning: already using the same window " .. RUNPRG_BUFFER_NAME)
    return
  endif
  if index(RUNPRG_ALLOWED_TYPES, &filetype) == -1
    EchoErrorMsg("Error: running filetype '" .. &filetype .. "' is not supported")
    return
  endif
  if &filetype == "sh"
    outmsg = systemlist(SHShellType() .. " " .. file)
  elseif &filetype == "python"
    outmsg = systemlist("python3 " .. file)
  elseif &filetype == "go"
    outmsg = systemlist("go run " .. file)
  endif
  if v:shell_error != 0
    EchoErrorMsg("Error: exit code " .. v:shell_error)
  endif
  if empty(outmsg)
    EchoWarningMsg("Warning: empty output")
    return
  endif
  if runwinid > 0
    win_gotoid(runwinid)
  elseif bufexists(RUNPRG_BUFFER_NAME) && getbufinfo(RUNPRG_BUFFER_NAME)[0].hidden
    execute "rightbelow split " .. RUNPRG_BUFFER_NAME
  else
    below new
    setlocal winfixheight
    setlocal winfixwidth
    setlocal buftype=nowrite
    setlocal noswapfile
    setlocal buflisted
    execute "file " .. RUNPRG_BUFFER_NAME
  endif
  appendbufline(RUNPRG_BUFFER_NAME, 0, outmsg)
  deletebufline(RUNPRG_BUFFER_NAME, '$')
  cursor(1, 1)
  execute "resize " .. len(outmsg)
  win_gotoid(selwinid)
enddef
