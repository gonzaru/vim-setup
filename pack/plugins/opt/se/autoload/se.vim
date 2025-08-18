vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# Se simple explorer

# See also ../ftplugin/se.vim

# do not read the file if it is already loaded or se is not enabled
if get(g:, 'autoloaded_se') || !get(g:, 'se_enabled')
  finish
endif
g:autoloaded_se = true

# script local variables
const BUFFER_NAME = $"se_{strcharpart(sha256('se'), 0, 8)}"
var PREV_CWD: string
var PREV_CWDS: list<string>

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

# returns an indicator that identifies a file (*/=@|)
def FileIndicator(file: string): string
  var ftype = getftype(file)
  var symbol: string
  if ftype == "dir"
    symbol = "/"
  elseif ftype == "file" && executable(file)
    symbol = "*"
  elseif ftype == "link"
    symbol = "@"
  elseif ftype == "fifo"
    symbol = "|"
  elseif ftype == "socket"
    symbol = "="
  else
    symbol = ""
  endif
  return symbol
enddef

# returns the permissions of the given file
def FilePerms(file: string): string
  return getfperm(file)
enddef

# gets Se buffer id
def GetSeBufId(): number
  var bid = -1
  for buf in getbufinfo()
    if fnamemodify(buf.name, ":t") == BUFFER_NAME && getbufvar(buf.bufnr, '&filetype') == "se"
      bid = buf.bufnr
      break
    endif
  endfor
  return bid
enddef

# help information
export def Help()
  var lines =<< trim END
    e        # edit the current file [<CR>]
    E        # edit the current file and toggle Se
    <SPACE>  # edit the current file and stay in Se
    s        # edit the current file in split mode
    S        # edit the current file in split mode and toggle Se
    v        # edit the current file in a vertical split mode
    V        # edit the current file in a vertical split mode and toggle Se
    t        # edit the current file in a tab
    T        # edit the current file in a tab and toggle Se
    p        # preview the current file in a window
    P        # close the preview window currently open
    d        # change to home directory [~]
    g        # change to prompt directory
    y        # toggle to show only directories
    b        # change to parent directory [-]
    f        # change to previous directory
    F        # follow the current file
    r        # refresh the current directory
    h        # resize Se window to the left
    l        # resize Se window to the right
    =        # resize Se window to default size
    +        # resize Se window to maximum column size
    o        # toggle the position of the hidden files
    u        # toggle to show the file permissions
    m        # check the default app for mime type
    M        # set default app for mime type
    c        # open the file with a custom program
    C        # open the file with the default program
    w        # change to git root directory
    W        # change to custom root directory (g:se_rootdir)
    z        # set the current directory as custom root directory
    Z        # unset the custom root directory
    .        # toggle the visualization of the hidden files
    <ESC>    # close Se window
    H        # shows Se help information [K]
  END
  echo join(lines, "\n")
enddef

# populates Se
def Populate(cwddir: string)
  var parent2cwd: string
  var parentcwd: string
  var hidden: list<string>
  var nohidden: list<string>
  var lsf: list<string>
  var curwildignore = &l:wildignore
  execute $"setlocal wildignore={g:se_fileignore}"
  if g:se_hiddenshow
    hidden = map(
      sort(globpath(cwddir, ".*", 0, 1)),
      "split(v:val, '/')[-1] .. FileIndicator(v:val) .. (g:se_permsshow ? ' ' .. FilePerms(v:val) : '')"
    )[2 : ]
  endif
  nohidden = map(
    sort(globpath(cwddir, "*", 0, 1)),
    "split(v:val, '/')[-1] .. FileIndicator(v:val) .. (g:se_permsshow ? ' ' .. FilePerms(v:val) : '')"
  )
  execute $"setlocal wildignore={curwildignore}"
  lsf = g:se_hiddenfirst ? extend(hidden, nohidden) : extend(nohidden, hidden)
  if len(lsf) > 0
    appendbufline(BUFFER_NAME, 0, g:se_onlydirs ? filter(lsf, 'isdirectory(v:val)') : lsf)
  else
    EchoWarningMsg($"Warning: the directory '{fnamemodify(cwddir, ':t')}' is empty")
    sleep! 1
    redraw!
  endif
  try
    parent2cwd = split(cwddir, "/")[-2]
  catch /^Vim\%((\a\+)\)\=:E684:/  # E684: List index out of range
    parent2cwd = '/'
  endtry
  try
    parentcwd = split(cwddir, "/")[-1]
  catch /^Vim\%((\a\+)\)\=:E684:/  # E684: List index out of range
    parentcwd = '/'
  endtry
  appendbufline(BUFFER_NAME, 0, [$"../ [{parent2cwd}]"])
  appendbufline(BUFFER_NAME, 1, [$"./ [{parentcwd}]"])
  deletebufline(BUFFER_NAME, '$')
  cursor(line('$') > 2 ? 3 : 1, 1)
enddef

# set custom root directory
export def SetRootDir(s: string)
  g:se_rootdir = s
enddef

# set prevcwd
def SetPrevCwd(s: string)
  if isdirectory(s)
    PREV_CWD = s
  endif
enddef

# get prevcwd
def GetPrevCwd(): string
  return PREV_CWD
enddef

# set prevcwds
def SetPrevCwds(s: string): void
  var cwd: string
  if !isdirectory(s)
    return
  endif
  if empty(PREV_CWDS)
    add(PREV_CWDS, s)
  else
    cwd = getcwd()
    if cwd != "/" && PREV_CWDS[-1] != cwd
      add(PREV_CWDS, s)
    endif
    if len(PREV_CWDS) > g:se_prevdirhist
      remove(PREV_CWDS, 0)
    endif
  endif
enddef

# get prevcwds
export def GetPrevCwds(): list<string>
  return PREV_CWDS
enddef

# shows Se
def Show(filepath: string)
  var prevcwd: string
  var bid = GetSeBufId()
  var cwddir = getcwd()
  if bid < 1
    prevcwd = !empty(filepath) ? fnamemodify(filepath, ":p:h") : cwddir
    if g:se_position == "right"
      # put into the last right window
      botright vnew
    else
      # put into to the first left window
      topleft vnew
    endif
    silent execute $"file {BUFFER_NAME}"
    setlocal filetype=se
    execute $"lcd {fnameescape(prevcwd)}"
    Populate(prevcwd)
    setlocal nomodifiable
    Resize(g:se_resizemaxcol ? "maxcol" : "default")
    SearchFile(filepath)
  elseif bufnr() == bid
    setlocal modifiable
    silent deletebufline(BUFFER_NAME, 1, '$')
    Populate(cwddir)
    setlocal nomodifiable
    if g:se_resizemaxcol
      Resize("maxcol")
    endif
  endif
enddef

# searches Se file
def SearchFile(file: string): void
  var modfile: string
  if empty(file)
    return
  endif
  modfile = fnamemodify(substitute(file, '\~$', "", ""), ":t")
  silent! search('^' .. modfile .. '.\?\(*\|@\)\?$')
enddef

# toggles Se
export def Toggle(filepath: string): void
  var bufinfo: list<dict<any>>
  var bid = GetSeBufId()
  if bid < 1
    Show(filepath)
    return
  endif
  bufinfo = getbufinfo(bid)
  if bufinfo[0].hidden
    if g:se_position == "right"
      # put into the last right window
      execute $"vertical botright sbuffer {bid}"
    else
      # put into the first left window
      execute $"vertical topleft sbuffer {bid}"
    endif
    execute $"lcd {fnameescape(GetPrevCwd())}"
    Resize(g:se_resizemaxcol ? "maxcol" : "default")
    if g:se_followfile
      FollowFile(filepath)
    endif
  elseif bufnr() != bid
    SetPrevCwd(getcwd(bufwinid(bid)))
    if bufwinid(bid) != -1
      win_execute(bufwinid(bid), "close")
    elseif tabpagenr('$') >= 2
      # bufwinid() only works with the current tab page
      for window in getbufinfo(bid)[0]['windows']
        win_execute(window, "close")
      endfor
    endif
  else
    SetPrevCwd(getcwd())
    close
    # go to the previous window
    win_gotoid(win_getid(winnr('#')))
  endif
enddef

# toggles Se hidden files
export def ToggleHiddenFiles(filepath: string, mode: string)
  var selfile = substitute(getline('.'), '[/@\*\|=]$', '', '')
  if mode == "position"
    g:se_hiddenshow = true
    g:se_hiddenfirst = !g:se_hiddenfirst
  elseif mode == "show"
    g:se_hiddenshow = !g:se_hiddenshow
  endif
  Refresh(expand('%:p'))
  cursor(3, 1)
  SearchFile(selfile)
enddef

# toggles Se to show the file permissions
export def TogglePermsShow()
  g:se_permsshow = !g:se_permsshow
  Refresh(expand('%:p'))
enddef

# toggles Se to show only directories
export def ToggleOnlyDirsShow()
  g:se_onlydirs = !g:se_onlydirs
  Refresh(expand('%:p'))
enddef

# automatic follow file
export def AutoFollowFile(filepath: string): void
  var bufinfo: list<dict<any>>
  var selwinid: number
  var bid = GetSeBufId()
  if bid < 1 || bufnr() == bid
    return
  endif
  bufinfo = getbufinfo(bid)
  if !bufinfo[0].hidden
    win_execute(bufwinid(bid), $"FollowFile('{filepath}')")
  endif
enddef

# follows Se file
export def FollowFile(filepath: string)
  var cwddir = !empty(filepath) ? fnamemodify(filepath, ":p:h") : getcwd()
  execute $"lcd {fnameescape(cwddir)}"
  Show(filepath)
  SearchFile(filepath)
enddef

# refresh Se
export def Refresh(filepath: string)
  var curline = substitute(getline('.'), '*$', "", "")
  Show(filepath)
  SearchFile(curline)
enddef

# edit the current file
def Edit(file: string)
  var bid: number
  if winnr('$') >= 2
    if g:se_position == "right"
      wincmd W
    else
      wincmd w
    endif
    execute $"edit {file}"
  else
    if g:se_position == "right"
      execute $"vnew {file}"
    else
      execute $"rightbelow vnew {file}"
    endif
    bid = GetSeBufId()
    win_execute(bufwinid(bid), "Resize(g:se_resizemaxcol ? 'maxcol' : 'default')")
  endif
enddef

# edit the current file and stay in Se
def EditKeep(file: string)
  var bid: number
  if winnr('$') >= 2
    if g:se_position == "right"
      win_execute(win_getid(winnr() - 1), $"edit {file}")
    else
      win_execute(win_getid(winnr() + 1), $"edit {file}")
    endif
    if g:se_resizemaxcol
      Resize("maxcol")
    endif
  else
    if g:se_position == "right"
      execute $"vnew {file}"
    else
      execute $"rightbelow vnew {file}"
    endif
    bid = GetSeBufId()
    win_gotoid(bufwinid(bid))
    Resize(g:se_resizemaxcol ? "maxcol" : "default")
  endif
enddef

# preview the current file in a window
def EditPedit(file: string)
  var bid = GetSeBufId()
  if winnr('$') >= 2
    if g:se_position == "right"
      win_execute(win_getid(winnr() - 1), $"pedit {file}")
    else
      win_execute(win_getid(winnr() + 1), $"pedit {file}")
    endif
    wincmd P
    resize
    win_gotoid(bufwinid(bid))
  else
    if g:se_position == "right"
      execute $"vertical pedit {file}"
    else
      execute $"vertical rightbelow pedit {file}"
    endif
    win_gotoid(bufwinid(bid))
    Resize(g:se_resizemaxcol ? "maxcol" : "default")
  endif
enddef

# edit the current file in split mode
def EditSplitH(file: string)
  var bid: number
  if winnr('$') >= 2
    if g:se_position == "right"
      wincmd W
    else
      wincmd w
    endif
    execute $"split {file}"
  else
    if g:se_position == "right"
      execute $"vsplit {file}"
    else
      execute $"rightbelow vsplit {file}"
    endif
    bid = GetSeBufId()
    win_execute(bufwinid(bid), "Resize(g:se_resizemaxcol ? 'maxcol' : 'default')")
  endif
enddef

# edit the current file in a vertical split mode
def EditSplitV(file: string)
  var bid: number
  if winnr('$') >= 2
    if g:se_position == "right"
      wincmd W
      execute $"rightbelow vsplit {file}"
    else
      wincmd w
      execute $"leftabove vsplit {file}"
    endif
  else
    if g:se_position == "right"
      execute $"vsplit {file}"
    else
      execute $"rightbelow vsplit {file}"
    endif
    bid = GetSeBufId()
    win_execute(bufwinid(bid), "Resize(g:se_resizemaxcol ? 'maxcol' : 'default')")
  endif
enddef

# edit the current file in a tab
def EditTab(file: string)
  if g:se_position == "right"
    execute $":-tabedit {file}"
  else
    execute $"tabedit {file}"
  endif
enddef

# remove the file indicators
def RemoveFileIndicators(filepath: string): string
  return (
    match(filepath, '^\.\.\?/ \[.*\]$') != -1 && index([1, 2], getpos('.')[1]) >= 0
    ? split(filepath, " ")[0]
    : fnamemodify(substitute(filepath, '*\|@$', "", ""), ":p")
  )
enddef

# remove the file perms
def RemoveFilePerms(filepath: string): string
  return g:se_permsshow ? join(split(filepath)[0 : (-1 - 1)]) : filepath
enddef

# opens the file with a custom program
export def OpenWith(filepath: string, default: bool): void
  var program: string
  var runprg: string
  var selfile: string
  var withterm: string
  if !default
    program = input($"Open the file '{fnamemodify(filepath, ":.")}' with: ", "", "shellcmd")
    if empty(program)
      return
    endif
  endif
  runprg = !empty(program) ? program : g:se_opentool
  if !executable(split(runprg)[0])
    EchoErrorMsg($"Error: the program '{runprg}' is missing")
    return
  endif
  redraw!
  selfile = fnameescape(fnamemodify(RemoveFileIndicators(RemoveFilePerms(filepath)), ":."))
  job_start($'/bin/sh -c "exec setsid {runprg} \"' .. selfile .. '\" >/dev/null 2>&1')
enddef

# checks the file mime type
export def CheckMimeType(filepath: string)
 var xdgtype: string
 var xdgprg: string
 var mimetype: string
 var mimeprg: string
 var filetype: string
 var fileprg: string
 var output: list<string>
 var selfile = shellescape(RemoveFileIndicators(RemoveFilePerms(filepath)))
 if executable("xdg-mime")
   xdgtype = trim(system($"xdg-mime query filetype {selfile}"))
   xdgprg = trim(system($"xdg-mime query default {xdgtype}"))
   add(output, $"xdg-mime: '{xdgtype}' ({xdgprg})")
 else
   add(output, $"xdg-mime: command not found")
 endif
 if executable("mimetype")
   mimetype = trim(system($"mimetype --brief {selfile}"))
   mimeprg = trim(system($"xdg-mime query default {mimetype}"))
   add(output, $"mimetype: '{mimetype}' ({mimeprg})")
 else
  add(output, "mimetype: command not found")
 endif
 if executable("file")
   filetype = trim(system($"file --brief --mime-type {selfile}"))
   fileprg = trim(system($"xdg-mime query default {filetype}"))
   add(output, $"file:     '{filetype}' ({fileprg})")
 else
   add(output, "file: command not found")
 endif
 echo join(output, "\n")
enddef

# sets the default app for the mime type
export def SetMimeType(filepath: string): void
  var program: string
  var selfile = shellescape(RemoveFileIndicators(RemoveFilePerms(filepath)))
  var filemime = trim(system($"xdg-mime query filetype {selfile}"))
  var defprgmime = trim(system($"xdg-mime query default {filemime}"))
  program = input($"Set default mime type '{filemime}' ({defprgmime}): ")
  program = substitute(program, '\.desktop$', "", "")
  redraw
  if empty(program)
    return
  endif
  system($"xdg-mime default {program}.desktop {filemime}")
  defprgmime = trim(system($"xdg-mime query default {filemime}"))
  if v:shell_error != 0
    EchoErrorMsg($"Error: failed to set the default mime for '{filemime}'")
  else
    echom $"The default mime type for '{filemime}' is now ({defprgmime})"
  endif
enddef

# goes to directory
def GoDir(dir: string, setcwd: bool): void
  if !isdirectory(dir)
    EchoErrorMsg($"Error: the directory '{dir}' is not a directory")
    return
  endif
  if setcwd
    SetPrevCwds(getcwd())
  endif
  execute $"lcd {fnameescape(dir)}"
  Show(dir)
enddef

# goes to git root dir directory
export def GoDirGit()
   var groot = trim(system("git rev-parse --show-toplevel"))
   if isdirectory(groot)
     GoDir(groot, true)
    else
      EchoErrorMsg($"Error: does not have a git root directory")
   endif
enddef

# goes to home directory
export def GoDirHome()
  GoDir(getenv('HOME'), true)
enddef

# goes to custom root directory
export def GoDirRoot(): void
  # fallback to git root
  if empty(g:se_rootdir)
    g:se_rootdir = trim(system("git rev-parse --show-toplevel"))
  endif
  if empty(g:se_rootdir) || !isdirectory(g:se_rootdir)
    EchoErrorMsg($"Error: 'g:se_rootdir' is empty or is not a directory")
    return
  endif
  GoDir(g:se_rootdir, true)
enddef

# goes to parent directory
export def GoDirParent()
  var dir = fnamemodify(getcwd(), ":t")
  cursor(1, 1)
  GoFile(getline('.'), "edit")
  SearchFile(dir)
enddef

# goes to previous directory
export def GoDirPrev(): void
  if empty(PREV_CWDS)
    return
  endif
  GoDir(remove(PREV_CWDS, -1), false)
  if !empty(PREV_CWDS)
    SearchFile(PREV_CWDS[-1])
  endif
enddef

# goes to directory via prompt
export def GoDirPrompt()
  var dir = fnamemodify(input("Go to directory: ", "", "dir"), ":p:h")
  redraw!
  GoDir(dir, true)
enddef

# goes to file or directory
export def GoFile(filepath: string, mode: string): void
  var cwddir: string
  var dochdir = true
  var selfile: string
  if bufnr() != GetSeBufId()
    return
  endif
  if g:se_autochdir
    cwddir = getcwd()
  endif
  selfile = RemoveFileIndicators(RemoveFilePerms(filepath))
  if selfile == "../" && !empty(g:se_rootdir)
    var kdir = fnamemodify(g:se_rootdir, ":p")
    var pdir = fnamemodify("../", ":p")
    if stridx(pdir, kdir) == -1
      EchoWarningMsg($"g:se_rootdir: {fnamemodify(g:se_rootdir, ':p:~')}")
      return
    endif
  endif
  if isdirectory(selfile)
    GoDir(selfile, true)
    if g:se_autochdir
      cwddir = getcwd()
    endif
    dochdir = false
  elseif mode == "edit"
    Edit(selfile)
  elseif mode == "editk"
    EditKeep(selfile)
  elseif mode == "pedit"
    EditPedit(selfile)
  elseif mode == "split"
    EditSplitH(selfile)
  elseif mode == "vsplit"
    EditSplitV(selfile)
  elseif mode == "tabedit"
    EditTab(selfile)
  endif
  if dochdir && g:se_autochdir
    execute $"lcd {cwddir}"
  endif
enddef

# resize Se window
export def Resize(mode: string)
  if mode == "left"
    execute $"vertical resize {(g:se_position == 'right' ? '+1' : '-1')}"
  elseif mode == "right"
    execute $"vertical resize {(g:se_position == 'right' ? '-1' : '+1')}"
  elseif mode == "default"
    execute $"vertical resize {g:se_winsize + wincol() - 1}"
  elseif mode == "restore"
    execute $"vertical resize {g:se_winsize + wincol() - 1}"
    cursor(line('.'), 1)
  elseif mode == "maxcol"
    execute $"vertical resize {max(map(getline(1, '$'), 'len(v:val)')) + wincol() - 1}"
  endif
enddef
