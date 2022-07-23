vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_runprg') || !get(g:, 'runprg_enabled') || &cp
  finish
endif
g:autoloaded_runprg = 1

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

# detects if the shell is sh or bash using shebang
def SHShellType(): string
  if &filetype != "sh"
    EchoErrorMsg("Error: filetype '" .. &filetype .. "' is not supported")
    return ''
  endif
  return getline(1) =~ "bash$" ? "bash" : "sh"
enddef

# run
export def Run(): void
  var curbufname = bufname('%')
  var curfile = expand('%:p')
  if index(["sh", "python", "go"], &filetype) == -1
    EchoErrorMsg("Error: running filetype '" .. &filetype .. "' is not supported")
    return
  endif
  if &filetype == "sh"
    echo system(SHShellType() .. " " .. curfile)
  elseif &filetype == "python"
    echo system("python3 " .. curfile)
  elseif &filetype == "go"
    echo system("go run " .. curfile)
  endif
  if v:shell_error
    EchoErrorMsg("Error: exit code " .. v:shell_error)
  endif
enddef

# run using a window
export def RunWindow(): void
  var bufoutname = "runoutput"
  var curbufname = bufname('%')
  var curfile = expand('%:p')
  var curwinid = win_getid()
  var prevwinid = bufexists(bufoutname) ? bufwinid(bufoutname) : -1
  var out: list<string>
  if curwinid == prevwinid
    EchoWarningMsg("Warning: already using the same window " .. bufoutname)
    return
  endif
  if index(["sh", "python", "go"], &filetype) == -1
    EchoErrorMsg("Error: running filetype '" .. &filetype .. "' is not supported")
    return
  endif
  if &filetype == "sh"
    out = systemlist(SHShellType() .. " " .. curfile)
  elseif &filetype == "python"
    out = systemlist("python3 " .. curfile)
  elseif &filetype == "go"
    out = systemlist("go run " .. curfile)
  endif
  if v:shell_error
    EchoErrorMsg("Error: exit code " .. v:shell_error)
  endif
  if empty(out)
    EchoWarningMsg("Warning: empty output")
    return
  endif
  if prevwinid > 0
    win_gotoid(prevwinid)
  else
    below new
    setlocal winfixheight
    setlocal winfixwidth
    setlocal buftype=nowrite
    setlocal noswapfile
    setlocal buflisted
    execute "file " .. bufoutname
  endif
  appendbufline('%', 0, out)
  deletebufline('%', '$')
  cursor(1, 1)
  execute "resize " .. len(out)
  win_gotoid(curwinid)
enddef
