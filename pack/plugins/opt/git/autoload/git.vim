vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_git') || !get(g:, 'git_enabled')
  finish
endif
g:autoloaded_git = true

# script local variables
const GIT_BUFFER_NAME = "git_" .. strftime('%Y%m%d%H%M%S', localtime())
const GIT_FILE_TYPE = "gittig"
var GIT_FILE: string

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

# gets the git previous file
export def GetGitPrevFile(): string
  return GIT_FILE
enddef

# sets the git previous file
def SetGitPrevFile(file: string)
  if filereadable(file)
    GIT_FILE = file
  else
    GIT_FILE = ""
  endif
enddef

# gets the git file type
export def GetGitFileType(): string
  return GIT_FILE_TYPE
enddef

# closes the git window
export def Close()
  var gitwinid = GetGitBufWinId()
  if gitwinid > 0
    win_execute(gitwinid, "bw")
  endif
enddef

# help information
export def Help()
  var lines =<< trim END
    <CR>   # shows git commit
    <ESC>  # closes git window
    gb     # shows git blame
    gB     # shows git blame (short version)
    gd     # shows git diff file
    gh     # shows git help information [H]
    gl     # shows git log file
    gL     # shows git log one file
    gs     # shows git show file
    gS     # shows git status file
  END
  echo join(lines, "\n")
enddef

# git blame
export def Blame(file: string, cwddir: string, short: bool, selwin: bool): void
  var curline = line('.')
  var curcol = col('.')
  var curwin = win_getid(winnr())
  var shortopts = short ? '--date short' : ''
  if !filereadable(file)
    EchoErrorMsg($"Error: file {file} is not readable")
    return
  endif
  Run($"git blame {shortopts} {file}", cwddir, selwin)
  if selwin
    wincmd H
    wincmd =
    cursor(curline, curcol)
    setlocal syntax=git
    win_gotoid(curwin)
    win_execute(GetGitBufWinId(), 'setlocal scrollbind')
    win_execute(curwin, 'setlocal scrollbind')
  else
    # TODO: selwin false
  endif
enddef

# checks if it is a valid git commit hash
def IsValidHash(hash: string): bool
  return hash =~ '^\x\{7,40\}$'
enddef

# checks if it is a valid git repo
def IsValidRepo(cwddir: string): bool
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
    execute $"setlocal filetype={GIT_FILE_TYPE}"
  endif
enddef

# shows the git commit
export def ShowCommit(line: string, cwddir: string, selwin: bool): void
  var commit: string
  if empty(trim(line))
    return
  endif
  commit = split(substitute(line, '^commit ', "", ""), " ")[0]
  if IsValidHash(commit)
    Run($"git show {commit}", cwddir, selwin)
  endif
enddef

# git run
export def Run(args: string, cwddir: string, selwin: bool): void
  var outmsg: list<string>
  var gitwinid = GetGitBufWinId()
  var curfile = expand('%:p')
  var selwinid = win_getid()
  if selwinid == gitwinid
    Close()
  endif
  if !IsValidRepo(cwddir)
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
  SetGitPrevFile(curfile)
  SetupWindow()
  gitwinid = GetGitBufWinId()
  appendbufline(GIT_BUFFER_NAME, 0, outmsg)
  deletebufline(GIT_BUFFER_NAME, '$')
  win_execute(gitwinid, "cursor(1, 1)")
  win_execute(gitwinid, $"resize {len(outmsg)}")
  if !selwin
    win_gotoid(selwinid)
  endif
enddef
