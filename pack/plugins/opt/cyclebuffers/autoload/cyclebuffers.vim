vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_cyclebuffers') || !get(g:, 'cyclebuffers_enabled') || &cp
  finish
endif
g:autoloaded_cyclebuffers = 1

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
  var bufinfo = getbufinfo({'buflisted': 1})
  var buflist: list<string>
  var curbuf = resolve(fnamemodify(bufname("%"), ":~"))
  var idx: number
  if len(bufinfo) == 1
    EchoWarningMsg("Warning: already using only one buffer")
    return
  endif
  for buf in bufinfo
    add(buflist, resolve(fnamemodify(bufname(buf.name), ":~")))
  endfor
  topleft new
  appendbufline('%', 0, buflist)
  deletebufline('%', '$')
  execute "resize " .. line('$')
  setlocal filetype=cb
  idx = index(buflist, curbuf)
  if idx >= 0
    cursor(idx + 1, 1)
  endif
enddef

# go to the selected buffer
export def SelectBuffer(file: string)
  var prevwinid = bufwinid('#')
  close
  win_gotoid(prevwinid)
  execute "edit " .. fnameescape(file)
enddef
