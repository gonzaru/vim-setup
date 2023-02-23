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

# prints error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# prints warning message and saves the message in the message-history
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
    if fnamemodify(b.name, ":t") == SE_BUFFER_NAME && getbufvar(b.bufnr, '&filetype') == "se"
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
    -        # change to parent directory
    ~        # change to home directory
    r        # refresh the current directory
    f        # follow the current file
    h        # resize Se window to the left
    l        # resize Se window to the right
    o        # toggle the position of the hidden files
    =        # resize Se window to default size [<BS>]
    <ESC>    # close Se window
    H        # shows Se help information [K]
  END
  echo join(lines, "\n")
enddef

# populates Se
def Populate(cwddir: string)
  var hidden = map(sort(globpath(cwddir, ".*", 0, 1)), 'split(v:val, "/")[-1] .. FileIndicator(v:val)')[2 : ]
  var nohidden = map(sort(globpath(cwddir, "*", 0, 1)), 'split(v:val, "/")[-1] .. FileIndicator(v:val)')
  var parent2cwd: string
  var parentcwd: string
  var lsf = get(g:, 'se_hiddenfirst') ? extend(hidden, nohidden) : extend(nohidden, hidden)
  if len(lsf) > 0
    appendbufline(SE_BUFFER_NAME, 0, lsf)
  else
    EchoWarningMsg("Warning: directory " .. fnamemodify(cwddir, ":t") .. " is empty")
    sleep 1
    redraw!
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
  appendbufline(SE_BUFFER_NAME, 0, ['../ [' .. parent2cwd .. ']'])
  appendbufline(SE_BUFFER_NAME, 1, ['./ [' .. parentcwd .. ']'])
  deletebufline(SE_BUFFER_NAME, '$')
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

# shows Se
def Show(filepath: string)
  var bid = GetSeBufId()
  var cwddir = getcwd()
  var prevcwd: string
  if bid < 1
    prevcwd = !empty(filepath) ? fnamemodify(filepath, ":p:h") : cwddir
    if get(g:, 'se_position') == "right"
      # put into the last right window
      botright vnew
    else
      # put into to the first left window
      topleft vnew
    endif
    silent execute "file " .. SE_BUFFER_NAME
    setlocal filetype=se
    execute "lcd " .. fnameescape(prevcwd)
    Populate(prevcwd)
    setlocal nomodifiable
    execute "vertical resize " .. g:se_winsize
    if get(g:, 'se_followfile')
      SearchFile(filepath)
    endif
  else
    if bufnr() == bid
      setlocal modifiable
      silent deletebufline(SE_BUFFER_NAME, 1, '$')
      Populate(cwddir)
      setlocal nomodifiable
    endif
  endif
enddef

# toggles Se
export def Toggle()
  var filepath = expand('%:p')
  var bufinfo: list<dict<any>>
  var bid = GetSeBufId()
  if bid > 0
    bufinfo = getbufinfo(bid)
    if bufinfo[0].hidden
      if get(g:, 'se_position') == "right"
        # put into the last right window
        execute "vertical botright sbuffer " .. bid
      else
        # put into the first left window
        execute "vertical topleft sbuffer " .. bid
      endif
      execute "lcd " .. fnameescape(GetPrevCwd())
      execute "vertical resize " .. g:se_winsize
      if get(g:, 'se_followfile')
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

# searches Se file
def SearchFile(file: string)
  var modfile: string
  if !empty(file)
    modfile = fnamemodify(substitute(file, '\~$', "", ""), ":t")
    silent! search('^' .. modfile .. '.\?\(*\|@\)\?$')
  endif
enddef

# automatic follow file
export def AutoFollowFile(filepath: string): void
  var bid = GetSeBufId()
  var bufinfo: list<dict<any>>
  var selwinid: number
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
  var cwddir: string
  cwddir = !empty(filepath) ? fnamemodify(filepath, ":p:h") : getcwd()
  execute "lcd " .. fnameescape(cwddir)
  Show(filepath)
  SearchFile(filepath)
enddef

# refresh Se
export def Refresh()
  var filepath = expand('%:p')
  var curline = substitute(getline('.'), '*$', "", "")
  Show(filepath)
  SearchFile(curline)
enddef

# edit the current file
def Edit(file: string)
  var bid: number
  if winnr('$') >= 2
    if get(g:, 'se_position') == "right"
      wincmd W
    else
      wincmd w
    endif
    execute "edit " .. file
  else
    if get(g:, 'se_position') == "right"
      execute "vnew " .. file
    else
      execute "rightbelow vnew " .. file
    endif
    bid = GetSeBufId()
    win_execute(bufwinid(bid), "vertical resize " .. g:se_winsize)
  endif
enddef

# edit the current file and stay in Se
def EditKeep(file: string)
  var bid: number
  if winnr('$') >= 2
    if get(g:, 'se_position') == "right"
      win_execute(win_getid(winnr() - 1), "edit " .. file)
    else
      win_execute(win_getid(winnr() + 1), "edit " .. file)
    endif
  else
    if get(g:, 'se_position') == "right"
      execute "vnew " .. file
    else
      execute "rightbelow vnew " .. file
    endif
    bid = GetSeBufId()
    win_gotoid(bufwinid(bid))
    execute "vertical resize " .. g:se_winsize
  endif
enddef

# preview the current file in a window
def EditPedit(file: string)
  var bid = GetSeBufId()
  if winnr('$') >= 2
    if get(g:, 'se_position') == "right"
      win_execute(win_getid(winnr() - 1), "pedit " .. file)
    else
      win_execute(win_getid(winnr() + 1), "pedit " .. file)
    endif
    wincmd P
    resize
    win_gotoid(bufwinid(bid))
  else
    if get(g:, 'se_position') == "right"
      execute "vertical pedit " .. file
    else
      execute "vertical rightbelow pedit " .. file
    endif
    win_gotoid(bufwinid(bid))
    execute "vertical resize " .. g:se_winsize
  endif
enddef

# edit the current file in split mode
def EditSplitH(file: string)
  var bid: number
  if winnr('$') >= 2
    if get(g:, 'se_position') == "right"
      wincmd W
    else
      wincmd w
    endif
    execute "split " .. file
  else
    if get(g:, 'se_position') == "right"
      execute "vsplit " .. file
    else
      execute "rightbelow vsplit " .. file
    endif
    bid = GetSeBufId()
    win_execute(bufwinid(bid), "vertical resize " .. g:se_winsize)
  endif
enddef

# edit the current file in a vertical split mode
def EditSplitV(file: string)
  var bid: number
  if winnr('$') >= 2
    if get(g:, 'se_position') == "right"
      wincmd W
      execute "rightbelow vsplit " .. file
    else
      wincmd w
      execute "leftabove vsplit " .. file
    endif
  else
    if get(g:, 'se_position') == "right"
      execute "vsplit " .. file
    else
      execute "rightbelow vsplit " .. file
    endif
    bid = GetSeBufId()
    win_execute(bufwinid(bid), "vertical resize " .. g:se_winsize)
  endif
enddef

# edit the current file in a tab
def EditTab(file: string)
  if get(g:, 'se_position') == "right"
    execute ":-tabedit " .. file
  else
    execute "tabedit " .. file
  endif
enddef

# goes to directory
export def GoDir(cwddir: string)
  execute "lcd " .. fnameescape(cwddir)
  Show(cwddir)
enddef

# goes to file or directory
export def GoFile(filepath: string, mode: string): void
  var selfile: string
  if bufnr() != GetSeBufId()
    return
  endif
  selfile = (
    match(filepath, '^\.\.\?/ \[.*\]$') != -1 && index([1, 2], getpos('.')[1]) >= 0
    ? split(filepath, " ")[0]
    : fnamemodify(substitute(filepath, '*\|@$', "", ""), ":p")
  )
  if isdirectory(selfile)
    GoDir(selfile)
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
