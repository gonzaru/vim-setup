vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_git') || !get(g:, 'git_enabled')
  finish
endif
g:autoloaded_git = true

# script local variables
const GIT_BUFFER_NAME = "git_" .. strftime('%Y%m%d%H%M%S', localtime())

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

# gets the git buffer window id
def GetGitBufWinId(): number
  return bufexists(GIT_BUFFER_NAME) ? bufwinid(GIT_BUFFER_NAME) : -1
enddef

# close
export def Close()
  var gitwinid = GetGitBufWinId()
  if gitwinid > 0
    win_execute(gitwinid, "bw")
  endif
enddef

# checks if it is a valid git repo
def ValidRepo(cwddir: string): bool
  var outmsg = systemlist($"cd {cwddir} && git rev-parse --is-inside-work-tree")[0]
  return !v:shell_error && outmsg == "true"
enddef

# git setup window
def SetupWindow()
  var bid = GetGitBufWinId()
  if bid > 0
    win_gotoid(bid)
  elseif bufexists(GIT_BUFFER_NAME) && getbufinfo(GIT_BUFFER_NAME)[0].hidden
    if g:git_position == 'bottom'
      execute $"rightbelow split {GIT_BUFFER_NAME}"
    else
      execute $"topleft split {GIT_BUFFER_NAME}"
    endif
  else
    if g:git_position == 'bottom'
      below new
    else
      new
    endif
    silent execute $"file {GIT_BUFFER_NAME}"
    setlocal winfixheight
    setlocal winfixwidth
    setlocal buftype=nowrite
    setlocal noswapfile
    setlocal buflisted
    setlocal filetype=git
    setlocal syntax=on
  endif
enddef

# git blame
export def Blame(file: string, cwddir: string): void
  if !filereadable(file)
    EchoErrorMsg($"Error: {fnamemodify(file, ':~')} is not a file or cannot be read")
  else
    Run($"git blame {file}", cwddir)
  endif
enddef

# git run
export def Run(args: string, cwddir: string): void
  var outmsg: list<string>
  var gitwinid = GetGitBufWinId()
  var selwinid = win_getid()
  if selwinid == gitwinid
    EchoWarningMsg($"Warning: already using the same window {GIT_BUFFER_NAME}")
    return
  endif
  if !ValidRepo(cwddir)
    EchoErrorMsg($"Error: {fnamemodify(cwddir, ':~')} is not a valid git repo")
    return
  endif
  outmsg = systemlist($"cd {cwddir} && {args}")
  if v:shell_error != 0
    EchoErrorMsg($"Error: exit code {v:shell_error}")
  endif
  if empty(outmsg)
    EchoWarningMsg("Warning: empty output")
    return
  endif
  SetupWindow()
  gitwinid = GetGitBufWinId()
  appendbufline(GIT_BUFFER_NAME, 0, outmsg)
  deletebufline(GIT_BUFFER_NAME, '$')
  win_execute(gitwinid, "cursor(1, 1)")
  win_execute(gitwinid, $"resize {len(outmsg)}")
  win_gotoid(selwinid)
enddef
