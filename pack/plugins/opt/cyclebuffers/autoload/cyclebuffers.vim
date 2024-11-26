vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_cyclebuffers') || !get(g:, 'cyclebuffers_enabled')
  finish
endif
g:autoloaded_cyclebuffers = true

# script local variables
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
    e        # edit the current buffer [<CR>]
    s        # edit the current buffer in split mode
    v        # edit the current buffer in a vertical split mode
    t        # edit the current buffer in a tab
    <ESC>    # close cyclebuffers window
    H        # shows cyclebuffers help information [K]
  END
  echo join(lines, "\n")
enddef

# cycle between buffers
export def Cycle(): void
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

# go to the selected buffer
export def SelectBuffer(line: number, mode: string)
  var prevwinid = bufwinid('#')
  var bufnr = GetBufferNum(line)
  close
  win_gotoid(prevwinid)
  if mode == "edit"
    execute $"buffer {bufnr}"
  elseif mode == "split"
    execute $"sbuffer {bufnr}"
  elseif mode == "vsplit"
    execute $"vertical sbuffer {bufnr}"
  elseif mode == "tabedit"
    execute $"tab sbuffer {bufnr}"
  endif
enddef
