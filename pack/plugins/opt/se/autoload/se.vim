vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# Se simple explorer

# See also ../../ftplugin/se.vim

# do not read the file if it is already loaded or se is not enabled
if exists('g:autoloaded_se') || !get(g:, 'se_enabled') || &cp
  finish
endif
g:autoloaded_se = 1

# script local variables
var se_oldcwd = ""

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
def GetBufId(): number
  for b in getbufinfo()
    if getbufvar(b.bufnr, '&filetype') == "se"
      return b.bufnr
    endif
  endfor
  return 0
enddef

# help information
export def Help()
  echo "e        # edit the current file [<CR>]"
  echo "E        # edit the current file and toggle Se"
  echo "<SPACE>  # edit the current file and stay in Se"
  echo "s        # edit the current file in split mode"
  echo "S        # edit the current file in split mode and toggle Se"
  echo "v        # edit the current file in a vertical split mode"
  echo "V        # edit the current file in a vertical split mode and toggle Se"
  echo "t        # edit the current file in a tab"
  echo "p        # preview the current file in a window"
  echo "P        # close the preview window currently open"
  echo "-        # changes to parent directory"
  echo "r        # lists the current directory"
  echo "f        # follow the current file"
  echo "=        # resize Se window [<BS>]"
  echo "<ESC>    # close Se window"
  echo "h        # shows Se help information [K]"
enddef

# populates Se
def ListPopulate()
  var cwddir = getcwd()
  var hidden = map(sort(globpath(cwddir, ".*", 0, 1)), 'split(v:val, "/")[-1] .. FileIndicator(v:val)')[2 : ]
  var nohidden = map(sort(globpath(cwddir, "*", 0, 1)), 'split(v:val, "/")[-1] .. FileIndicator(v:val)')
  var parent2cwd: string
  var parentcwd: string
  var lsf = extend(nohidden, hidden)
  if len(lsf) > 0
    appendbufline('%', 0, lsf)
    deletebufline('%', '$')
  endif
  cursor(1, 1)
  try
    parent2cwd = split(getcwd(), "/")[-2]
  catch
    parent2cwd = '/'
  endtry
  appendbufline('%', 0, ['../ [' .. parent2cwd .. ']'])
  try
    parentcwd = split(getcwd(), "/")[-1]
  catch
    parentcwd = '/'
  endtry
  appendbufline('%', 1, ['./ [' .. parentcwd .. ']'])
  if !len(lsf)
    deletebufline('%', '$')
    cursor(1, 1)
    EchoWarningMsg("Warning: directory is empty")
  endif
enddef

# lists Se
def List()
  var bufname = bufname('%')
  var sb = GetBufId()
  if !sb
    se_oldcwd = !empty(bufname) ? fnamemodify(bufname, ":~:h") : getcwd()
    setlocal nosplitright
    vertical new
    silent file se
    setlocal splitright
    setlocal filetype=se
    if se_oldcwd != '.'
      execute "lcd " .. fnameescape(se_oldcwd)
    endif
    ListPopulate()
    execute ":vertical resize " .. g:se_winsize
  else
    if win_getid() != bufwinid(sb)
      win_gotoid(bufwinid(sb))
    endif
    if &filetype == "se"
      setlocal modifiable
    endif
    silent deletebufline('%', 1, '$')
    ListPopulate()
  endif
  se_oldcwd = getcwd()
  setlocal nomodifiable
enddef

# toggles Se
export def Toggle()
  var bufinfo: list<dict<any>>
  var sb = GetBufId()
  if sb > 0
    bufinfo = getbufinfo(sb)
    if bufinfo[0].hidden
      setlocal nosplitright
      execute "vertical sbuffer " .. sb
      setlocal splitright
      execute "lcd " .. fnameescape(se_oldcwd)
      execute "vertical resize " .. g:se_winsize
    else
      if win_getid() != bufwinid(sb)
        win_gotoid(bufwinid(sb))
      endif
      if &filetype == "se"
        close
      endif
    endif
  else
    List()
  endif
enddef

# search Se file
def SearchFile(file: string)
  if !empty(file)
    search('^' .. file .. '.\?$')
  endif
enddef

# follows Se file
export def FollowFile()
  var prevcwd: string
  var prevfile: string
  var prevtailfile: string
  var sewinid = win_getid()
  win_gotoid(win_getid(winnr('#')))
  prevfile = bufname('%')
  prevcwd = fnamemodify(prevfile, ":~:h")
  prevtailfile = fnamemodify(prevfile, ":t")
  win_gotoid(sewinid)
  execute ":lcd " .. fnameescape(prevcwd)
  List()
  SearchFile(prevtailfile)
enddef

# refresh Se list
export def RefreshList()
  var se_prevline = substitute(fnameescape(getline('.')), '*$', "", "")
  cursor(2, 1)
  List()
  SearchFile(se_prevline)
enddef

# goes to file
export def Gofile(mode: string): void
  var curline = substitute(getline('.'), '*$', "", "")
  var firstchar = matchstr(curline, "^.")
  var lastchar = matchstr(curline, ".$")
  var mode_list: list<string>
  var oldcwd: string
  var oldwinid: number
  var sb = GetBufId()
  if mode == "edit" && firstchar == "." && lastchar == ']' && isdirectory(split(curline, " ")[0])
    try
      oldcwd = split(getcwd(), "/")[-1] .. "/"
    catch
      oldcwd = "/"
    endtry
    execute "lcd " .. getcwd(winnr()) .. "/" .. fnameescape(split(curline, " ")[0])
    List()
    SearchFile(oldcwd)
  elseif mode == "edit" && lastchar == '/' && isdirectory(curline)
    execute "lcd " .. getcwd(winnr()) .. "/" .. fnameescape(curline)
    List()
  elseif mode == "edit" && lastchar == '@' && isdirectory(resolve(substitute(curline, '@$', "", "")))
    execute "lcd " .. fnameescape(resolve(substitute(curline, '@$', "", "")))
    List()
  else
    if lastchar == '@'
      curline = resolve(substitute(curline, '@$', "", ""))
      if !filereadable(curline)
        EchoErrorMsg("Error: symlink is broken")
        return
      endif
    endif
    if !filereadable(curline)
      EchoErrorMsg("Error: file is no longer available")
      return
    endif
    mode_list = ["edit", "editk", "pedit", "split"]
    if index(mode_list, mode) >= 0
      oldcwd = getcwd()
      oldwinid = win_getid()
      win_gotoid(win_getid(winnr('#')))
      if win_getid() != oldwinid
        if mode == "edit" || mode == "editk"
          execute "edit " .. oldcwd .. "/" .. curline
          if mode == "editk"
            win_gotoid(bufwinid(sb))
          endif
        elseif mode == "pedit"
          execute "pedit " .. oldcwd .. "/" .. curline
          win_gotoid(bufwinid(sb))
        elseif mode == "split"
          execute "split " .. oldcwd .. "/" .. curline
        endif
      else
        # vsplit as default if is the same Se window
        execute "vsplit " .. oldcwd .. "/" .. curline
        if mode == "editk" || mode == "pedit"
          win_gotoid(bufwinid(sb))
        endif
      endif
    elseif mode ==  "vsplit"
      execute "vsplit " .. curline
    elseif mode ==  "tabedit"
      execute "tabedit " .. curline
    endif
  endif
enddef
