vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_git') || !get(g:, 'git_enabled')
  finish
endif
g:autoloaded_git = true

# script local variables
const GIT_BUFFER_NAME = $"git_{strcharpart(sha256('git'), 0, 8)}"
const GIT_FILE_TYPE = "gitscm"
var GIT_FILE: string

# prints the error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# gets the git buffer window id
def GitBufWinId(): number
  return bufexists(GIT_BUFFER_NAME) ? bufwinid(GIT_BUFFER_NAME) : -1
enddef

# gets the git previous file
export def GitPrevFile(): string
  return GIT_FILE
enddef

# sets the git previous file
def SetGitPrevFile(file: string)
  if filereadable(file)
    GIT_FILE = file
  elseif !IsValidHash(file)
    GIT_FILE = ""
  endif
enddef

# gets the git file type
export def GitFileType(): string
  return GIT_FILE_TYPE
enddef

# closes the git window
export def Close()
  var gitwinid = GitBufWinId()
  if gitwinid > 0
    win_execute(gitwinid, "bw")
  endif
enddef

# help information
export def Help()
  var lines =<< trim END
    <CR>   shows a commit or switch to a branch
    <ESC>  closes the git window
    gA     git add file
    gb     git blame file
    gB     git blame --date short file
    gC     git checkout file
    gd     git diff file
    gh     help information [<F1>, H]
    gl     git log file
    gL     git log --oneline file
    gR     git restore --staged file
    gs     git status file
    gS     git show file
  END
  echo join(lines, "\n")
enddef

# shows revison and author of each line of a file
export def Blame(file: string, cwddir: string, short: bool, selwin: bool): void
  var curline = line('.')
  var curcol = col('.')
  var curwin = win_getid(winnr())
  var shortopts = short ? '--date short' : ''
  if !filereadable(file)
    EchoErrorMsg($"Error: the file '{file}' is not readable")
    return
  endif
  cursor(1, 1)
  Run($"git blame {shortopts} {file}", cwddir, selwin)
  if selwin
    cursor(1, 1)
    wincmd H
    wincmd =
    setlocal syntax=git scrollbind cursorbind cursorline
    win_gotoid(curwin)
    setlocal scrollbind cursorbind cursorline
    cursor(curline, curcol)
  else
    # TODO: selwin false
  endif
enddef

# restores a working tree file
export def CheckOutFile(file: string, cwddir: string, short: bool, selwin: bool): void
  var autoread_orig: bool
  if !filereadable(file)
    EchoErrorMsg($"Error: the file '{file}' is not readable")
    return
  endif
  Run($"git checkout -- {file}", cwddir, selwin)
  autoread_orig = &l:autoread
  setlocal autoread
  silent checktime
  &l:autoread = autoread_orig
enddef

# checks if the local branch exists
def BranchExists(branch: string, cwddir: string): bool
  system($"cd {cwddir} && git show-ref --verify --quiet refs/heads/{branch}")
  return !v:shell_error
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
  var bid = GitBufWinId()
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

# menu action
def MenuAction(file: string, cwddir: string, selwin: bool): void
  var menu = ['diff', 'checkout', 'add', 'restore']
  var lenm = len(menu)
  var choice = inputlist(
    extend([ 'Select:'], map(copy(menu), (i, v) => printf($"{lenm >= 10 ? '%2d.' : '%d.'} %s", i + 1, v)))
  )
  if empty(choice)
    return
  endif
  if choice < 1 || choice > lenm
    EchoErrorMsg($"Error: wrong option '{choice}'")
    return
  endif
  var action = menu[choice - 1]
  var message = $"{toupper(action[0]) .. action[1 :]} file '{fnamemodify(trim(file), ':p:~')}'?"
	if action != 'diff' && confirm(message, "&Yes\n&No", 2) != 1
	  return
	endif
  if action == 'diff'
    Run($"git diff -- {file}", cwddir, selwin)
  elseif action == 'checkout'
    Run($"git checkout -- {file}", cwddir, selwin)
  elseif action == 'add'
    Run($"git add -- {file}", cwddir, selwin)
  elseif action == 'restore'
    Run($"git restore --staged -- {file}", cwddir, selwin)
  endif
  if action != 'diff'
    feedkeys("\<Esc>", 'n')
    Run($"git status --porcelain", cwddir, selwin)
  endif
enddef

# shows a commit or switch to a branch
export def DoAction(line: string, cwddir: string, selwin: bool): void
  var elem: string
  if empty(trim(line))
    return
  endif
  var hash = '^\x\{8\} '
  if line =~ '^commit ' || line =~ hash  # commit, hash
    if line =~ hash
      elem = split(line, " ")[0]
    else
      elem = substitute(line, '^commit ', "", "")
    endif
    if IsValidHash(elem)
      Run($"git show {elem}", cwddir, selwin)
    endif
  elseif line =~ '^* \|^  '  # branch
    elem = substitute(line, '^* \|^  ', "", "")
    if BranchExists(elem, cwddir)
      var curpos = getcurpos()
      Run($"git switch {elem}", cwddir, selwin)
      if get(g:, 'statusline_enabled')
        setpos('.', curpos)
        sleep! 200m
        doautocmd DirChanged
      endif
    endif
  elseif line =~ '^ M \|^?? \|^A '
    elem = substitute(line, '^ M \|^?? \|^A ', "", "")
    MenuAction(elem, cwddir, true)
  endif
enddef

# git run
export def Run(args: string, cwddir: string, selwin: bool): void
  var outmsg: list<string>
  var gitwinid = GitBufWinId()
  var curfile = split(args)[-1]
  var selwinid = win_getid()
  if selwinid == gitwinid
    Close()
  endif
  if !IsValidRepo(cwddir)
    EchoErrorMsg($"Error: '{fnamemodify(cwddir, ':~')}' is not a valid git repo")
    return
  endif
  outmsg = systemlist($"cd {cwddir} && {args}")
  if v:shell_error != 0
    EchoErrorMsg($"Error: output by args: '{args}, message: '{join(outmsg)}', status: 'NOK'")
    return
  endif
  if empty(outmsg)
    echomsg $"Info: empty output by args: '{args}', status: {v:shell_error == 0 ? 'OK' : 'NOK'}"
    return
  endif
  SetGitPrevFile(curfile)
  SetupWindow()
  gitwinid = GitBufWinId()
  silent deletebufline(GIT_BUFFER_NAME, 1, '$')
  appendbufline(GIT_BUFFER_NAME, 0, outmsg)
  deletebufline(GIT_BUFFER_NAME, '$')
  win_execute(gitwinid, "cursor(1, 1)")
  win_execute(gitwinid, $"resize {len(outmsg)}")
  win_execute(gitwinid, "setlocal syntax=git")
  if !selwin
    win_gotoid(selwinid)
  endif
enddef
