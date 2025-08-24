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
var node = {
  'prev': "",
  'cur': "",
  'next': "",
  'repn': 1
}
const BUFFER_NAME = $"se_{strcharpart(sha256('se'), 0, 8)}"

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
    a        # change to prompt directory
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
    <ESC>    # close Se window [q]
    H        # shows Se help information [K]
  END
  echo join(lines, "\n")
enddef

# sets custom root directory
export def SetRootDir(dir: string)
  g:se_rootdir = dir
enddef

# searches Se file
def SearchFile(file: string): void
  if empty(file) || g:se_onlydirs
    return
  endif
  var tail = split(file, '/')[-1]
  silent! search(tail .. '.\?\(*\|@\)\?$')
enddef

# closes Se
export def Close()
  var bid = GetSeBufId()
  if bufwinid(bid) != -1
    win_execute(bufwinid(bid), "close")
  endif
enddef

# setup
def Setup()
  if g:se_position == "right"
    # put into the last right window
    botright vnew
  else
    # put into to the first left window
    topleft vnew
  endif
  silent execute $"file {BUFFER_NAME}"
  setlocal filetype=se
  setlocal nomodifiable
enddef

# toggles Se
export def Toggle(file: string): void
  var bufinfo: list<dict<any>>
  var bid = GetSeBufId()
  if bid < 1
    Setup()
    Show(file, "new")
    cursor(2, 1)
    SearchFile(file)
    return
  endif
  if bufnr() == bid
    close
    win_gotoid(win_getid(winnr('#')))
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
    Resize(g:se_resizemaxcol ? "maxcol" : "default")
  elseif bufnr() != bid
    if bufwinid(bid) != -1
      win_execute(bufwinid(bid), "close")
    elseif tabpagenr('$') >= 2
      # bufwinid() only works with the current tab page
      for window in getbufinfo(bid)[0]['windows']
        win_execute(window, "close")
      endfor
    endif
  endif
enddef

# shows Se
def Show(file: string, mode: string)
  node.cur = substitute(fnamemodify(file, ':p:h:~'), "//", "/", "g")
  if mode == "new"
    node.repn = 1
  endif
  try
    node.prev = fnamemodify('/' .. join(split(node.cur, '/')[0 : - 2], '/'), ':~')
  catch /^Vim\%((\a\+)\)\=:E684:/  # E684: List index out of range
    node.prev = "/"
  endtry
  var hidden: list<string>
  var nohidden: list<string>
  var wildignore_orig = &l:wildignore
  execute $"setlocal wildignore={g:se_fileignore}"
  if g:se_hiddenshow
    hidden = sort(globpath(node.cur, ".*", 0, 1))
  endif
  nohidden = sort(globpath(node.cur, "*", 0, 1))
  execute $"setlocal wildignore={wildignore_orig}"
  var files = g:se_hiddenfirst ? extend(hidden, nohidden) : extend(nohidden, hidden)
  if g:se_onlydirs
    files = filter(copy(files), (_, val) => isdirectory(val))
  endif
  if mode == "add"
    node.repn = strlen(matchstr(getline('.'), '^\s*')) + 1
  endif
  var mfiles = mapnew(files, (_, val) =>
    repeat(' ', node.repn + 1) .. fnamemodify(val, ':t') .. FileIndicator(val)
    .. (g:se_permsshow ? ' ' .. FilePerms(val) : '')
  )
  setlocal modifiable
  if mode == "new"
    silent deletebufline(BUFFER_NAME, 1, '$')
    appendbufline(BUFFER_NAME, 0, extend([fnamemodify(node.cur, ':~')], mfiles))
    deletebufline(BUFFER_NAME, '$')
  elseif mode == "add"
    appendbufline(BUFFER_NAME, line('.'), mfiles)
    # cursor(line('.') + 1, col('.'))
  endif
  setlocal nomodifiable
  Resize(g:se_resizemaxcol ? "maxcol" : "default")
  # cursor(2, 1)
enddef

# find the parent directories
def FindParents(): string
  var prevs = []
  var cni = indent(line('.'))
  for num in range(line('.') - 1, 1, -1)
    if cni > indent(num)
      cni = indent(num)
      add(prevs, trim(getline(num)))
    endif
  endfor
  return join(reverse(prevs), '/')
enddef

# find the number of child directories
def FindNumChilds(): number
  var num = 0
  var cni = indent(line('.'))
  for line in range(line('.') + 1, line('$'))
    if indent(line) <= cni
      break
    endif
    if indent(line) > cni
      ++num
    endif
  endfor
  return num
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
  Refresh()
  cursor(2, 1)
  SearchFile(selfile)
enddef

# toggles Se to show the file permissions
export def TogglePermsShow()
  g:se_permsshow = !g:se_permsshow
  Refresh()
enddef

# toggles Se to show only directories
export def ToggleOnlyDirsShow()
  g:se_onlydirs = !g:se_onlydirs
  Refresh()
enddef

## automatic follow file
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
  Show(filepath, "new")
  SearchFile(filepath)
enddef

# refresh Se
export def Refresh()
  var cur = getline(1)
  var pos = getcurpos()
  execute $"lcd {cur}"
  Show(cur, "new")
  setpos('.', pos)
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
  return substitute(filepath, '*\|@$', "", "")
enddef

# remove the file perms
def RemoveFilePerms(filepath: string): string
  return g:se_permsshow ? join(split(filepath)[0 : (-1 - 1)]) : filepath
enddef

# opens the file with a custom program
export def OpenWith(filepath: string, default: bool): void
  var program: string
  var runprg: string
  var withterm: string
  var prev = FindParents()
  var fsel = RemoveFileIndicators($"{prev}/{trim(filepath)}")
  if !default
    program = input($"Open the file '{fnamemodify(fsel, ":.")}' with: ", "", "shellcmd")
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
  #var mfsel = fnameescape(RemoveFileIndicators(RemoveFilePerms(fsel)))
  var mfsel = fnameescape(fnamemodify(fsel, ':p'))
  job_start($'/bin/sh -c "exec setsid {runprg} \"' .. mfsel .. '\" >/dev/null 2>&1')
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
  var prev = FindParents()
  var fsel = RemoveFileIndicators($"{prev}/{trim(filepath)}")
  if executable("xdg-mime")
    xdgtype = trim(system($"xdg-mime query filetype {fsel}"))
    xdgprg = trim(system($"xdg-mime query default {xdgtype}"))
    add(output, $"xdg-mime: '{xdgtype}' ({xdgprg})")
  else
    add(output, $"xdg-mime: command not found")
  endif
  if executable("mimetype")
    mimetype = trim(system($"mimetype --brief {fsel}"))
    mimeprg = trim(system($"xdg-mime query default {mimetype}"))
    add(output, $"mimetype: '{mimetype}' ({mimeprg})")
  else
    add(output, "mimetype: command not found")
  endif
  if executable("file")
    filetype = trim(system($"file --brief --mime-type {fsel}"))
    fileprg = trim(system($"xdg-mime query default {filetype}"))
    add(output, $"file: '{filetype}' ({fileprg})")
  else
    add(output, "file: command not found")
  endif
  echo join(output, "\n")
enddef

# sets the default app for the mime type
export def SetMimeType(filepath: string): void
  var program: string
  var prev = FindParents()
  var fsel = RemoveFileIndicators($"{prev}/{trim(filepath)}")
  var filemime = trim(system($"xdg-mime query filetype {fsel}"))
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
export def GoDir(dir: string): void
  if !isdirectory(dir)
    EchoErrorMsg($"Error: the directory '{dir}' is not a directory")
    return
  endif
  execute $"lcd {fnameescape(dir)}"
  Show(dir, "new")
enddef

# goes to git root dir directory
export def GoDirGit()
  var groot = trim(system("git rev-parse --show-toplevel"))
  if isdirectory(groot)
    GoDir(groot)
  else
    EchoErrorMsg($"Error: does not have a git root directory")
  endif
enddef

# goes to home directory
export def GoDirHome()
  GoDir(getenv('HOME'))
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
  GoDir(g:se_rootdir)
enddef

# goes to parent directory
export def GoDirParent(): void
  if getcwd() == "/"
    return
  endif
  node.next = getcwd()
  execute $"lcd {getline(1)}"
  lcd ..
  node.cur = getcwd()
  Show(node.cur, "new")
  cursor(2, 1)
enddef

# goes to previous directory
export def GoDirPrev(): void
  if empty(node.next)
    return
  endif
  GoDir(node.next)
enddef

# goes to directory via prompt
export def GoDirPrompt()
  var dir = fnamemodify(input("Go to directory: ", "", "dir"), ":p:h")
  redraw!
  GoDir(dir)
enddef

# goes to file or directory
export def GoFile(file: string, mode: string): void
  var cline = line('.')
  var prev = FindParents()
  # TODO: check // or see simplify()
  var fsel = fnamemodify(RemoveFileIndicators(substitute($"{prev}/{trim(file)}", "//", "/", "g")), ":p")
  # TODO: show perms
  if g:se_permsshow
    EchoWarningMsg("currently disabled when 'g:se_permsshow' is true")
    return
  endif
  # first line
  if cline == 1
    # EchoWarningMsg("currently disabled for the first line")
    return
  endif
  # has subdirectory
  if HasChild(cline)
    var num = FindNumChilds()
    if num >= 1
      setlocal modifiable
      deletebufline(BUFFER_NAME, cline + 1, cline + num)
      setlocal nomodifiable
    endif
    return
  endif
  if isdirectory(fsel)
    node.cur = fsel
    execute $"lcd {node.cur}"
    Show(node.cur, "add")
  elseif mode == "edit"
    Edit(fsel)
  elseif mode == "editk"
    EditKeep(fsel)
  elseif mode == "pedit"
    EditPedit(fsel)
  elseif mode == "split"
    EditSplitH(fsel)
  elseif mode == "vsplit"
    EditSplitV(fsel)
  elseif mode == "tabedit"
    EditTab(fsel)
  endif
enddef

# has child (subdirectory)
def HasChild(cline: number): bool
  if cline != line('$') && indent(cline) < indent(cline + 1)
    return true
  endif
  return false
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
