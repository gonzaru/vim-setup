vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# Se simple explorer

# See also ../ftplugin/se.vim

# do not read the file if it is already loaded or se is not enabled
if exists('g:autoloaded_se') || !get(g:, 'se_enabled') || &cp
  finish
endif
g:autoloaded_se = 1

# script local variables
const SE_BUFFER_NAME = "se_" .. strftime('%Y%m%d%H%M%S', localtime())
var se_prevcwd: string
var se_prevwin: number

# prints error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom  msg
    echohl None
  endif
enddef

# prints warning message and saves the message in the message-history
# def EchoWarningMsg(msg: string)
#   if !empty(msg)
#     echohl WarningMsg
#     echom  msg
#     echohl None
#   endif
# enddef

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
  var bid = -1
  for b in getbufinfo()
    if fnamemodify(b.name, ":t") == SE_BUFFER_NAME && getbufvar(b.bufnr, '&filetype') == "se"
      bid = b.bufnr
      break
    endif
  endfor
  return bid
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
  echo "r        # refresh the current directory"
  echo "f        # follow the current file"
  echo "=        # resize Se window [<BS>]"
  echo "<ESC>    # close Se window"
  echo "h        # shows Se help information [K]"
enddef

# populates Se
def Populate(cwddir: string)
  var hidden = map(sort(globpath(cwddir, ".*", 0, 1)), 'split(v:val, "/")[-1] .. FileIndicator(v:val)')[2 : ]
  var nohidden = map(sort(globpath(cwddir, "*", 0, 1)), 'split(v:val, "/")[-1] .. FileIndicator(v:val)')
  var parent2cwd: string
  var parentcwd: string
  var lsf = get(g:, 'se_hiddenfirst') ? extend(hidden, nohidden) : extend(nohidden, hidden)
  if len(lsf) > 0
    appendbufline('%', 0, lsf)
  else
    # EchoWarningMsg("Warning: directory " .. fnamemodify(cwddir, ":~") .. " is empty")
  endif
  try
    parent2cwd = split(cwddir, "/")[-2]
  catch /^Vim\%((\a\+)\)\=:E684:/ # E684: List index out of range
    parent2cwd = '/'
  endtry
  try
    parentcwd = split(cwddir, "/")[-1]
  catch /^Vim\%((\a\+)\)\=:E684:/ # E684: List index out of range
    parentcwd = '/'
  endtry
  appendbufline('%', 0, ['../ [' .. parent2cwd .. ']'])
  appendbufline('%', 1, ['./ [' .. parentcwd .. ']'])
  deletebufline('%', '$')
  cursor(line('$') > 2 ? 3 : 1, 1)
enddef

# set prevcwd
def SetPrevCwd(s: string)
  se_prevcwd = s
enddef

# get prevcwd
def GetPrevCwd(): string
  return se_prevcwd
enddef

# set prevwin
def SetPrevWin(n: number)
  se_prevwin = n
enddef

# get prevwin
def GetPrevWin(): number
  return se_prevwin
enddef

# shows Se
def Show()
  var bid = GetBufId()
  var bufname = bufname('%')
  var cwddir = getcwd()
  var prevcwd: string
  if bid < 1
    SetPrevCwd(!empty(bufname) ? fnamemodify(bufname, ":~:h") : cwddir)
    SetPrevWin(win_getid())
    if get(g:, 'se_position') == "right"
      # go to the last right window
      win_gotoid(win_getid(winnr('$')))
      rightbelow vnew
    else
      # put into to the first left window
      topleft vnew
    endif
    execute "silent file " .. SE_BUFFER_NAME
    setlocal filetype=se
    prevcwd = GetPrevCwd()
    execute "lcd " .. fnameescape(prevcwd)
    Populate(prevcwd)
    setlocal nomodifiable
    execute "vertical resize " .. g:se_winsize
    if get(g:, 'se_followfile')
      SearchFile(fnamemodify(bufname, ":t"))
    endif
  else
    if fnamemodify(bufname('%'), ":t") == SE_BUFFER_NAME && &filetype == "se"
      SetPrevCwd(cwddir)
      setlocal modifiable
      silent deletebufline('%', 1, '$')
      Populate(cwddir)
      setlocal nomodifiable
    endif
  endif
enddef

# toggles Se
export def Toggle()
  var bufinfo: list<dict<any>>
  var bid = GetBufId()
  if bid > 0
    bufinfo = getbufinfo(bid)
    if bufinfo[0].hidden
      SetPrevWin(win_getid())
      if get(g:, 'se_position') == "right"
        # go to the last right window
        win_gotoid(win_getid(winnr('$')))
        execute "vertical rightbelow sbuffer " .. bid
      else
        # put into the first left window
        execute "vertical topleft sbuffer " .. bid
      endif
      execute "lcd " .. fnameescape(GetPrevCwd())
      execute "vertical resize " .. g:se_winsize
      if get(g:, 'se_followfile')
        FollowFile()
      endif
    else
      SetPrevWin(win_getid())
      if win_getid() != bufwinid(bid)
        win_gotoid(bufwinid(bid))
      endif
      if fnamemodify(bufinfo[0].name, ":t") == SE_BUFFER_NAME && &filetype == "se"
        close
        # go to the previous window
        win_gotoid(GetPrevWin())
      endif
    endif
  else
    Show()
  endif
enddef

# searches Se file
def SearchFile(file: string)
  if !empty(file)
    search('^' .. file .. '.\?$')
  endif
enddef

# follows Se file
export def FollowFile(): void
  var prevcwd: string
  var prevfile: string
  var selwinid: number
  if fnamemodify(bufname('%'), ":t") != SE_BUFFER_NAME || &filetype != "se"
    return
  endif
  selwinid = win_getid()
  win_gotoid(win_getid(winnr('#')))
  prevfile = bufname('%')
  prevcwd = !empty(prevfile) ? fnamemodify(prevfile, ":~:h") : getcwd()
  win_gotoid(selwinid)
  execute ":lcd " .. fnameescape(prevcwd)
  Show()
  SearchFile(fnamemodify(prevfile, ":t"))
enddef

# refresh Se
export def Refresh()
  var curline = substitute(fnameescape(getline('.')), '*$', "", "")
  Show()
  SearchFile(curline)
enddef

# edit the current file
def Edit(buffer: string)
  if winnr('$') >= 2
    if get(g:, 'se_position') == "right"
      win_gotoid(win_getid(winnr() - 1))
    else
      wincmd w
    endif
    execute "edit " .. buffer
  else
    if get(g:, 'se_position') == "right"
      execute "vnew " .. buffer
    else
      execute "rightbelow vnew " .. buffer
    endif
    vertical resize
    execute "vertical resize -" .. g:se_winsize
  endif
enddef

# edit the current file and stay in Se
def EditKeep(buffer: string)
  var selwinid = win_getid()
  Edit(buffer)
  win_gotoid(selwinid)
  execute "vertical resize " .. g:se_winsize
enddef

# preview the current file in a window
def EditPedit(buffer: string)
  var selwinid: number
  if winnr('$') >= 2
    selwinid = win_getid()
    if get(g:, 'se_position') == "right"
      win_gotoid(win_getid(winnr() - 1))
    else
      wincmd w
    endif
    execute "pedit " .. buffer
    wincmd P
    resize
    win_gotoid(selwinid)
  else
    execute "vertical pedit " .. buffer
    execute "vertical resize " .. g:se_winsize
  endif
enddef

# edit the current file in split mode
def EditSplitH(buffer: string)
  if winnr('$') >= 2
    if get(g:, 'se_position') == "right"
      win_gotoid(win_getid(winnr() - 1))
    else
      wincmd w
    endif
    execute "split " .. buffer
  else
    if get(g:, 'se_position') == "right"
      execute "vsplit " .. buffer
    else
      execute "rightbelow vsplit " .. buffer
    endif
    vertical resize
    execute "vertical resize -" .. g:se_winsize
  endif
enddef

# edit the current file in a vertical split mode
def EditSplitV(buffer: string)
  if winnr('$') >= 2
    if get(g:, 'se_position') == "right"
      win_gotoid(win_getid(winnr() - 1))
      execute "rightbelow vsplit " .. buffer
    else
      wincmd w
      execute "leftabove vsplit " .. buffer
    endif
  else
    if get(g:, 'se_position') == "right"
      execute "vsplit " .. buffer
    else
      execute "rightbelow vsplit " .. buffer
    endif
    vertical resize
    execute "vertical resize -" .. g:se_winsize
  endif
enddef

# edit the current file in a tab
def EditTab(buffer: string)
  if get(g:, 'se_position') == "right"
    execute ":-tabedit " .. buffer
  else
    execute "tabedit " .. buffer
  endif
enddef

# goes to file or directory
export def Gofile(mode: string): void
  var selfile: string
  if fnamemodify(bufname('%'), ":t") != SE_BUFFER_NAME || &filetype != "se"
    return
  endif
  selfile = (
    index([1, 2], getpos('.')[1]) >= 0
    ? split(getline('.'), " ")[0]
    : fnamemodify(substitute(getline('.'), '*\|@$', "", ""), ":p")
  )
  if isdirectory(selfile)
    execute "lcd " .. fnameescape(selfile)
    Show()
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
