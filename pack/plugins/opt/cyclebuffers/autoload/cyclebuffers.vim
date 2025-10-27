vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_cyclebuffers') || !get(g:, 'cyclebuffers_enabled')
  finish
endif
g:autoloaded_cyclebuffers = true

# script local variables
var PEDITID: number = -1
var LINEBUF: list<dict<any>>

# prints warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom msg
    echohl None
  endif
enddef

# help information
export def Help()
  var lines =<< trim END
    d        # delete the current buffer
    D        # delete the current buffer and stay in cyclebuffers window
    w        # wipe the current buffer
    W        # wipe the current buffer and stay in cyclebuffers window
    e        # edit the current buffer [<CR>]
    s        # edit the current buffer in split mode
    v        # edit the current buffer in a vertical split mode
    t        # edit the current buffer in a tab
    p        # edit the current buffer in a preview window [<Space>]
    P        # close the preview window
    J        # edit the next buffer in a preview window
    K        # edit the previous buffer in a preview window
    <ESC>    # close cyclebuffers window
    H        # shows cyclebuffers help information
  END
  echo join(lines, "\n")
enddef

# clear globals
def ClearGlobals()
  LINEBUF = []
  PEDITID = -1
enddef

# cycle between buffers
export def Cycle(): void
  ClearGlobals()
  if &filetype == "cb"
    EchoWarningMsg("Warning: already in the cyclebuffers window")
    return
  endif
  var idx: number
  var bufinfo = getbufinfo({'buflisted': 1})
  var curbufnr = bufnr("%")
  if len(bufinfo) == 1
    EchoWarningMsg("Warning: there is only one buffer available")
    return
  endif
  SetBufferLines(bufinfo)
  if g:cyclebuffers_position == "top"
    topleft split new
  else
    botright split new
  endif
  appendbufline('%', 0, GetBufferNames())
  deletebufline('%', '$')
  execute $"resize {line('$')}"
  setlocal filetype=cb
  idx = GetBufferLine(curbufnr)
  if idx >= 0
    cursor(idx, 1)
  endif
enddef

# cyle between old files
export def CycleOldFiles(): void
  ClearGlobals()
  if empty(v:oldfiles)
    EchoWarningMsg("Warning: 'v:oldfiles' is empty")
    return
  endif
  if g:cyclebuffers_position == "top"
    topleft split new
  else
    botright split new
  endif
  var limit = g:cyclebuffers_oldfiles_limit
  appendbufline('%', 0, limit > 0 ? v:oldfiles[0 : limit - 1] : v:oldfiles)
  deletebufline('%', '$')
  execute $"resize {line('$')}"
  setlocal filetype=cb
  cursor(1, 1)
enddef

# get the line number from buffer number
def GetBufferLine(bufnr: number): number
  for lb in LINEBUF
    if lb.bufnr == bufnr
      return lb.line
    endif
  endfor
  return -1
enddef

# get the buffer names
def GetBufferNames(): list<string>
  var buflname: list<string>
  for lb in LINEBUF
    add(buflname, lb.bufname)
  endfor
  return buflname
enddef

# get the buffer number from line number
export def GetBufferNum(line: number): number
  for lb in LINEBUF
    if lb.line == line
      return lb.bufnr
    endif
  endfor
  return -1
enddef

# set the buffer lines values from buffers
def SetBufferLines(bufinfo: list<dict<any>>)
  var num = 1
  LINEBUF = []
  for buf in bufinfo
    add(LINEBUF, {
      'line': num,
      'bufnr': buf.bufnr,
      'bufname': empty(buf.name) ? "[No Name]" : fnamemodify(bufname(buf.name), ":~")
    })
    ++num
  endfor
enddef

# close the preview window
export def ClosePreview()
  if PEDITID != -1
    win_execute(PEDITID, 'close')
  endif
enddef

# go to the selected buffer
export def SelectBuffer(line: number, mode: string): void
  var oldfile: string
  var prevwinid = bufwinid('#')
  var bufnr = !empty(LINEBUF) ? GetBufferNum(line) : -1

  # TODO: workaround for v:oldfiles
  if bufnr == -1
    oldfile = getline('.')
  endif

  if index(["delete", "wipe"], mode) >= 0 && !empty(oldfile)
    EchoWarningMsg($"Warning: cannot '{mode}' without buffer number")
    return
  endif

  if index(["delete-keep", "wipe-keep"], mode) >= 0 && empty(oldfile) && bufnr("#") == bufnr
    var bmode = split(mode, "-")[0]
    EchoWarningMsg($"Warning: cannot '{bmode}' and stay in the current buffer")
    return
  endif

  # close the cyclebuffers window
  if index(["delete-keep", "wipe-keep", "pedit"], mode) == -1
    if &filetype == "cb"
      close
    endif
    ClosePreview()
    win_gotoid(prevwinid)
  endif

  if mode == "edit"
    execute !empty(oldfile) ? $"edit {oldfile}" : $"buffer {bufnr}"
  elseif mode == "split"
    execute !empty(oldfile) ? $"split {oldfile}" : $"sbuffer {bufnr}"
  elseif mode == "vsplit"
    execute !empty(oldfile) ? $"vsplit {oldfile}" : $"vertical sbuffer {bufnr}"
  elseif mode == "tabedit"
    execute !empty(oldfile) ? $"tabedit {oldfile}" : $"tab sbuffer {bufnr}"
  elseif mode == "pedit"
    var winid = win_getid()
    var file = !empty(oldfile) ? oldfile : bufname(bufnr)
    execute $'keepalt vertical rightbelow pedit {file}'
    PEDITID = win_getid(winnr('#'))
    win_gotoid(winid)
    win_execute(winid, 'wincmd =')
    # win_execute(winid, $"vertical resize -{line('$')}")
  elseif mode == "delete" && empty(oldfile)
    execute $"bd {bufnr}"
  elseif mode == "wipe" && empty(oldfile)
    execute $"bw {bufnr}"
  elseif index(["delete-keep", "wipe-keep"], mode) >= 0 && empty(oldfile)
    var bmode = split(mode, "-")[0]
    execute $"b{bmode} {bufnr}"
    setlocal modifiable
    deletebufline('%', line('.'))
    setlocal nomodifiable
    execute $"resize {line('$')}"
    var bufinfo = getbufinfo({'buflisted': 1})
    SetBufferLines(bufinfo)
  endif
enddef
