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
  'next': [],
  'dirsep': '▸',
  # TODO: sub ▾
  'repn': 0
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

# applies Se colors
export def SetColors()
  # highlight colors
  # ../syntax/se.vim
  if g:se_colors
    # ownsyntax se
    clearmatches()
    matchadd('SeTop', '\%1l.*', 20)
    matchadd('SeFile',  '^\s\+.*[^/]$', 30)
    matchadd('SeDirectory', '^\s*\V' .. node.dirsep .. '\m\s\zs.\+/$', 40)
    matchadd('SeDirectorySep',  '^\s*\zs\V' .. node.dirsep .. '\m', 50)
    matchadd('SeHidden',  '^\s\+\zs\.', 60)
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
    e               # edit the current file [<CR>,<2-LeftMouse>]
    E               # edit the current file and toggle Se
    <Space>         # 1) file: edit the current file and stay in Se
                    # 2) dir: change the current directory as base
    s               # edit the current file in split mode
    S               # edit the current file in split mode and toggle Se
    v               # edit the current file in a vertical split mode
    V               # edit the current file in a vertical split mode and toggle Se
    t               # edit the current file in a tab
    T               # edit the current file in a tab and toggle Se
    p               # preview the current file in a window
    P               # close the preview window currently open
    d               # change to home directory [~]
    a               # change to prompt directory
    i               # toggle to show directories first
    y               # toggle to show only directories
    Y               # toggle to show only files
    b               # change to parent directory [-,<BackSpace>]
    f               # change to previous directory
    F               # follow the current file
    r               # refresh the current directory
    h               # resize Se window to the left
    l               # resize Se window to the right
    =               # resize Se window to default size
    +               # resize Se window to maximum column size
    o               # toggle the position of the hidden files
    u               # toggle to show the file permissions
    m               # check the default app for mime type
    M               # set default app for mime type
    c               # open the file with a custom program
    C               # open the file with the default program
    w               # change to git root directory
    W               # change to custom root directory (g:se_rootdir)
    z               # set the current directory as custom root directory
    Z               # unset the custom root directory
    .               # toggle the visualization of the hidden files
    <C-f>           # search files in the selected directory
    <C-g>           # grep files in the selected directory
    <2-RightMouse>  # find or grep files in the selected directory
    <ESC>           # close Se window [q]
    H               # shows Se help information [K]
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
  SetColors()
enddef

# toggles Se
export def Toggle(file: string): void
  var bufinfo: list<dict<any>>
  var bid = GetSeBufId()
  if bid < 1
    Setup()
    LS(file, "new")
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
    SetColors()
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

# filter list directory/file contents
def FilterLS(files: list<string>): list<string>
  var lsf = files
  # exclude hidden '.' and '..' directories
  if g:se_hiddenshow
    lsf = filter(copy(lsf), (_, val) => val !~ '\.\{1,2}$')
  endif
  if g:se_dirsfirst && !g:se_hiddenfirst
    var dirs = filter(copy(lsf), (_, val) => isdirectory(val))
    var nodirs = filter(copy(lsf), (_, val) => !isdirectory(val))
    lsf = extend(dirs, nodirs)
  endif
  if g:se_onlydirs
    lsf = filter(copy(lsf), (_, val) => isdirectory(val))
  elseif g:se_onlyfiles
    lsf = filter(copy(lsf), (_, val) => !isdirectory(val))
  endif
  var repn = indent(line('.')) + 2
  var mlsf = mapnew(lsf, (_, val) =>
    repeat(node.repn < 2 ? '' : ' ', repn)
    .. (isdirectory(val) ? node.dirsep .. ' ' : '  ')
    .. fnamemodify(val, ':t') .. FileIndicator(val)
    .. (g:se_permsshow ? ' ' .. FilePerms(val) : '')
  )
  return mlsf
enddef

# list directory/file contents
def LS(file: string, mode: string)
  node.cur = fnamemodify(file, ':p:h:~')
  node.repn = mode == "new" ? 0 : node.repn + 2
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
  var lsf = g:se_hiddenfirst ? extend(hidden, nohidden) : extend(nohidden, hidden)
  if !len(lsf)
    EchoWarningMsg($"Warning: the directory '{fnamemodify(node.cur, ':p:~')}' is empty")
    return
  endif
  var nlsf = FilterLS(lsf)
  setlocal modifiable
  if mode == "new"
    silent deletebufline(BUFFER_NAME, 1, '$')
    appendbufline(BUFFER_NAME, 0, extend([fnamemodify(node.cur, ':~')], nlsf))
    deletebufline(BUFFER_NAME, '$')
  elseif mode == "add"
    appendbufline(BUFFER_NAME, line('.'), nlsf)
    # cursor(line('.') + 1, col('.'))
  endif
  setlocal nomodifiable
  Resize(g:se_resizemaxcol ? "maxcol" : "default")
  # cursor(2, 1)
enddef

# find the parent directories
def FindParents(): string
  var prevs = []
  var top = getline(1)
  var cni = strlen(matchstr(RemoveDirSep(getline('.')), '^\s\+'))
  if cni == 0
    return top .. '/'
  endif
  for num in range(line('.') - 1, 1, -1)
    var line = RemoveDirSep(getline(num))
    var lcni = strlen(matchstr(line, '^\s\+'))
    if cni > lcni + 1
      cni = strlen(matchstr(line, '^\s\+'))
      add(prevs, trim(RemoveFileIndicators(RemoveDirSep(getline(num)))))
    endif
  endfor
  var result: string
  if empty(prevs) || top == join(prevs)
    result = top .. '/'
  else
    var sprevs = len(prevs) == 1 ? join(prevs) : join(reverse(prevs), '/')
    result = top .. '/' .. sprevs .. '/'
  endif
  return result
enddef

# find the number of child directories
def FindNumChilds(): number
  var num = 0
  var cli = RemoveDirSep(getline('.'))
  var cni = strlen(matchstr(cli, '^\s\+'))
  for nline in range(line('.') + 1, line('$'))
    var line = RemoveDirSep(getline(nline))
    var lcni = strlen(matchstr(line, '^\s\+'))
    if lcni <= cni
      break
    endif
    if lcni > cni + 1
      ++num
    endif
  endfor
  return num
enddef

# toggles Se hidden files
export def ToggleHiddenFiles(filepath: string, mode: string)
  var fsel = RemoveFileIndicators(getline('.'))
  if mode == "position"
    g:se_hiddenshow = true
    g:se_hiddenfirst = !g:se_hiddenfirst
  elseif mode == "show"
    g:se_hiddenshow = !g:se_hiddenshow
  endif
  Refresh()
  cursor(2, 1)
  SearchFile(fsel)
enddef

# toggles Se to show the file permissions
export def TogglePerms()
  g:se_permsshow = !g:se_permsshow
  Refresh()
enddef

# toggles Se to show directories first
export def ToggleDirsFirst()
  g:se_dirsfirst = !g:se_dirsfirst
  Refresh()
enddef

# toggles Se to show only directories
export def ToggleOnlyDirs()
  g:se_onlyfiles = false
  g:se_onlydirs = !g:se_onlydirs
  Refresh()
enddef

# toggles Se to show only files
export def ToggleOnlyFiles()
  g:se_onlydirs = false
  g:se_onlyfiles = !g:se_onlyfiles
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
  LS(filepath, "new")
  cursor(2, 1)
  SearchFile(filepath)
enddef

# refresh Se
export def Refresh()
  var cur = getline(1)
  var pos = getcurpos()
  execute $"lcd {cur}"
  LS(cur, "new")
  setpos('.', pos)
enddef

# edit the current file
def Edit(file: string)
  var bid: number
  if winnr('$') >= 2
    var wnr = win_getid(g:se_position == "right" ? winnr('h') : winnr('l'))
    if g:se_position == "right"
      win_execute(wnr, $"edit {file}")
    else
      win_execute(wnr, $"edit {file}")
    endif
    win_gotoid(wnr)
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
      win_execute(win_getid(winnr('h')), $"edit {file}")
    else
      win_execute(win_getid(winnr('l')), $"edit {file}")
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
      win_execute(win_getid(winnr('h')), $"pedit {file}")
    else
      win_execute(win_getid(winnr('l')), $"pedit {file}")
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
    var wnr = win_getid(g:se_position == "right" ? winnr('h') : winnr('l'))
    if g:se_position == "right"
      win_execute(wnr, $"split {file}")
    else
      win_execute(wnr, $"split {file}")
    endif
    wnr = win_getid(g:se_position == "right" ? winnr('h') : winnr('l'))
    win_gotoid(wnr)
  else
    if g:se_position == "right"
      execute $"split {file}"
    else
      execute $"rightbelow split {file}"
    endif
    bid = GetSeBufId()
    win_execute(bufwinid(bid), "Resize(g:se_resizemaxcol ? 'maxcol' : 'default')")
  endif
enddef

# edit the current file in a vertical split mode
def EditSplitV(file: string)
  var bid: number
  if winnr('$') >= 2
    var wnr = win_getid(g:se_position == "right" ? winnr('h') : winnr('l'))
    if g:se_position == "right"
      win_execute(wnr, $"rightbelow vsplit {file}")
    else
      win_execute(wnr, $"leftabove vsplit {file}")
    endif
    wnr = win_getid(g:se_position == "right" ? winnr('h') : winnr('l'))
    win_gotoid(wnr)
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
export def RemoveFileIndicators(file: string): string
  return trim(substitute(file, '*\|@$', "", ""), "/", 2)
enddef

# remove the file perms
def RemoveFilePerms(file: string): string
  return g:se_permsshow ? join(split(file)[0 : (-1 - 1)]) : file
enddef

# remove the directory separation
export def RemoveDirSep(file: string): string
  return substitute(file, node.dirsep, "", "")
enddef

# opens the file with a custom program
export def OpenWith(file: string, default: bool): void
  var program: string
  var runprg: string
  var prev = FindParents()
  var fsel = RemoveFileIndicators($"{prev}{trim(file)}")
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
  var mfsel = fnameescape(fnamemodify(fsel, ':p'))
  job_start($'/bin/sh -c "exec setsid {runprg} \"' .. mfsel .. '\" >/dev/null 2>&1')
enddef

# checks the file mime type
export def CheckMimeType(file: string)
  var output: list<string>
  var prev = FindParents()
  var fsel = RemoveFileIndicators($"{prev}/{trim(file)}")
  if executable("xdg-mime")
    var xdgtype = trim(system($"xdg-mime query filetype {fsel}"))
    var xdgprg = trim(system($"xdg-mime query default {xdgtype}"))
    add(output, $"xdg-mime: '{xdgtype}' ({xdgprg})")
  else
    add(output, $"xdg-mime: command not found")
  endif
  if executable("mimetype")
    var mimetype = trim(system($"mimetype --brief {fsel}"))
    var mimeprg = trim(system($"xdg-mime query default {mimetype}"))
    add(output, $"mimetype: '{mimetype}' ({mimeprg})")
  else
    add(output, "mimetype: command not found")
  endif
  if executable("file")
    var ftype = trim(system($"file --brief --mime-type {fsel}"))
    var fileprg = trim(system($"xdg-mime query default {ftype}"))
    add(output, $"file: '{ftype}' ({fileprg})")
  else
    add(output, "file: command not found")
  endif
  echo join(output, "\n")
enddef

# sets the default app for the mime type
export def SetMimeType(filepath: string): void
  var prev = FindParents()
  var fsel = RemoveFileIndicators($"{prev}/{trim(filepath)}")
  var filemime = trim(system($"xdg-mime query filetype {fsel}"))
  var defprgmime = trim(system($"xdg-mime query default {filemime}"))
  var program = input($"Set default mime type '{filemime}' ({defprgmime}): ")
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
  LS(dir, "new")
  cursor(2, 1)
enddef

# goes to git root dir directory
export def GoDirGit()
  var groot = systemlist("git rev-parse --show-toplevel")[0]
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

# goes to base directory or edit the current file and stay in Se
export def GoDirBaseOrEditKeep(file: string): void
  # first line
  if line('.') == 1
    # EchoWarningMsg("currently disabled for the first line")
    return
  endif
  var prev = FindParents()
  var fsel = fnamemodify(
    RemoveFileIndicators(
      $"{prev}{trim(RemoveDirSep(file))}"
    ), ":p"
  )
  if isdirectory(fsel)
    GoDir(fsel)
  else
    EditKeep(fsel)
  endif
enddef

# goes to custom root directory
export def GoDirRoot(): void
  # fallback to git root
  if empty(g:se_rootdir)
    g:se_rootdir = systemlist("git rev-parse --show-toplevel")[0]
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
  add(node.next, getcwd())
  execute $"lcd {getline(1)}"
  lcd ..
  node.cur = getcwd()
  LS(node.cur, "new")
  cursor(2, 1)
enddef

# goes to previous directory
export def GoDirPrev(): void
  if empty(node.next)
    return
  endif
  GoDir(remove(node.next, -1))
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
  var fsel = fnamemodify(
    RemoveFileIndicators(
      $"{prev}{trim(RemoveDirSep(file))}"
    ), ":p"
  )
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
    LS(node.cur, "add")
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
  var lcur = RemoveDirSep(getline(cline))
  var lnext = RemoveDirSep(getline(cline + 1))
  var ncur = strlen(matchstr(lcur, '^\s\+'))
  var nnext = strlen(matchstr(lnext, '^\s\+'))
  if ncur + 1 < nnext
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
