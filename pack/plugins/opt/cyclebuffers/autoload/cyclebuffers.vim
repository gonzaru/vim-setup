vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_cyclebuffers') || !get(g:, 'cyclebuffers_enabled')
  finish
endif
g:autoloaded_cyclebuffers = true

# script local variables
final LINEBUF = {}

# prints warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom  msg
    echohl None
  endif
enddef

# cycle between buffers
export def Cycle(): void
  var idx: number
  var num: number
  var buflist: list<string>
  var bufinfo = getbufinfo({'buflisted': 1})
  var curbuf = fnamemodify(bufname("%"), ":~")
  if len(bufinfo) == 1
    EchoWarningMsg("Warning: there is only one buffer available")
    return
  endif
  num = 1
  for buf in bufinfo
    # TODO: add terminal
    if getbufvar(buf.bufnr, '&buftype') == 'terminal'
      continue
    endif
    add(buflist, fnamemodify(bufname(buf.name), ":~"))
    SetBufferNum(num, buf.bufnr)
    ++num
  endfor
  if g:cyclebuffers_position == "top"
    topleft split new
  else
   botright split new
  endif
  appendbufline('%', 0, buflist)
  deletebufline('%', '$')
  execute $"resize {line('$')}"
  setlocal filetype=cb
  idx = index(buflist, curbuf)
  if idx >= 0
    cursor(idx + 1, 1)
  endif
enddef

# get the buffer number from line number
export def GetBufferNum(line: number): number
  return LINEBUF[line]
enddef

# set the buffer number from line number
def SetBufferNum(line: number, bufnr: number)
  LINEBUF[line] = bufnr
enddef

# go to the selected buffer
export def SelectBuffer(line: number)
  var prevwinid = bufwinid('#')
  close
  win_gotoid(prevwinid)
  execute $"buffer {GetBufferNum(line)}"
enddef
