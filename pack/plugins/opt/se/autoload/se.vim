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

# gets Se buffer id
def GetSeBufId(): number
  var bid = -1
  for b in getbufinfo()
    if fnamemodify(b.name, ":t") == BUFFER_NAME && getbufvar(b.bufnr, '&filetype') == "se"
      bid = b.bufnr
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
    b        # change to parent directory [-]
    f        # change to previous directory
    F        # follow the current file
    r        # refresh the current directory
    h        # resize Se window to the left
    l        # resize Se window to the right
    o        # toggle the position of the hidden files
    m        # check the default app for mime type
    M        # set default app for mime type
    c        # open the file with a custom program
    C        # open the file with the default program
    .        # toggle the visualization of the hidden files
    =        # resize Se window to default size
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
  var curwildignore = &l:wildignore
  execute $"setlocal wildignore={g:se_fileignore}"
  if g:se_hiddenshow
    hidden = map(sort(globpath(cwddir, ".*", 0, 1)), 'split(v:val, "/")[-1] .. FileIndicator(v:val)')[2 : ]
  endif
  var nohidden = map(sort(globpath(cwddir, "*", 0, 1)), 'split(v:val, "/")[-1] .. FileIndicator(v:val)')
  execute $"setlocal wildignore={curwildignore}"
  var lsf = g:se_hiddenfirst ? extend(hidden, nohidden) : extend(nohidden, hidden)
  if len(lsf) > 0
    appendbufline(BUFFER_NAME, 0, lsf)
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
  appendbufline(BUFFER_NAME, 0, ['../ [' .. parent2cwd .. ']'])
  appendbufline(BUFFER_NAME, 1, ['./ [' .. parentcwd .. ']'])
  deletebufline(BUFFER_NAME, '$')
  cursor(line('$') > 2 ? 3 : 1, 1)
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
def SetPrevCwds(s: string)
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
    execute $"vertical resize {g:se_winsize}"
    if g:se_followfile
      SearchFile(filepath)
    endif
  else
    if bufnr() == bid
      setlocal modifiable
      silent deletebufline(BUFFER_NAME, 1, '$')
      Populate(cwddir)
      setlocal nomodifiable
    endif
  endif
enddef

# searches Se file
def SearchFile(file: string)
  var modfile: string
  if !empty(file)
    modfile = fnamemodify(substitute(file, '\~$', "", ""), ":t")
    silent! search('^' .. modfile .. '.\?\(*\|@\)\?$')
  endif
enddef

# toggles Se
export def Toggle(filepath: string)
  var bufinfo: list<dict<any>>
  var bid = GetSeBufId()
  if bid > 0
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
      execute $"vertical resize {g:se_winsize}"
      if g:se_followfile
        FollowFile(filepath)
      endif
    else
      if bufnr() != bid
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
    endif
  else
    Show(filepath)
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
    win_execute(bufwinid(bid), "FollowFile('" .. filepath .. "')")
  endif
enddef

# follows Se file
export def FollowFile(filepath: string): void
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
    win_execute(bufwinid(bid), $"vertical resize {g:se_winsize}")
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
  else
    if g:se_position == "right"
      execute $"vnew {file}"
    else
      execute $"rightbelow vnew {file}"
    endif
    bid = GetSeBufId()
    win_gotoid(bufwinid(bid))
    execute $"vertical resize {g:se_winsize}"
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
    execute $"vertical resize {g:se_winsize}"
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
    win_execute(bufwinid(bid), $"vertical resize {g:se_winsize}")
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
    win_execute(bufwinid(bid), $"vertical resize {g:se_winsize}")
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
  selfile = fnameescape(fnamemodify(RemoveFileIndicators(filepath), ":."))
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
 var selfile = shellescape(RemoveFileIndicators(filepath))
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
export def SetMimeType(filepath: string)
  var program: string
  var selfile = shellescape(RemoveFileIndicators(filepath))
  var filemime = trim(system($"xdg-mime query filetype {selfile}"))
  var defprgmime = trim(system($"xdg-mime query default {filemime}"))
  program = input($"Set default mime type '{filemime}' ({defprgmime}): ")
  program = substitute(program, '\.desktop$', "", "")
  redraw
  if !empty(program)
    system($"xdg-mime default {program}.desktop {filemime}")
    defprgmime = trim(system($"xdg-mime query default {filemime}"))
    if v:shell_error != 0
      EchoErrorMsg($"Error: failed to set the default mime for '{filemime}'")
    else
      echom $"The default mime type for '{filemime}' is now ({defprgmime})"
    endif
  endif
enddef

# goes to directory
def GoDir(dir: string, setcwd: bool)
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

# goes to home directory
export def GoDirHome()
  GoDir(getenv('HOME'), true)
enddef

# goes to parent directory
export def GoDirParent()
  var dir = fnamemodify(getcwd(), ":t")
  cursor(1, 1)
  GoFile(getline('.'), "edit")
  SearchFile(dir)
enddef

# goes to previous directory
export def GoDirPrev()
  if !empty(PREV_CWDS)
    GoDir(remove(PREV_CWDS, -1), false)
    if !empty(PREV_CWDS)
      SearchFile(PREV_CWDS[-1])
    endif
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
  var selfile: string
  if bufnr() != GetSeBufId()
    return
  endif
  selfile = RemoveFileIndicators(filepath)
  if isdirectory(selfile)
    GoDir(selfile, true)
  else
    if mode == "edit"
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
  endif
enddef
