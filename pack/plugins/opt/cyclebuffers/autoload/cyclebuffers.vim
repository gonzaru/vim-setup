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
  var curbuf = substitute(bufname("%"), $HOME .. "/" .. $USER .. "/", "~/", "")
  var bufinfo = getbufinfo({'buflisted': 1})
  var buflist: list<string>
  var bul: list<string>
  if len(bufinfo) == 1
    EchoWarningMsg("Warning: already using only one buffer")
    return
  endif
  buflist = []
  for buf in bufinfo
    bul = split(substitute(buf.name, $HOME .. "/" .. $USER .. "/", "~/", ""))
    extend(buflist, bul)
  endfor
  topleft new
  appendbufline('%', 0, buflist)
  deletebufline('%', '$')
  execute "resize " .. line('$')
  setlocal filetype=cb
  for i in range(1, line('$'))
    if curbuf == getline(i)
      cursor(i, 1)
      break
    endif
  endfor
enddef

# go to the selected buffer
export def SelectBuffer()
  var curbufid = winbufnr(winnr())
  var prevwinid = bufwinid('#')
  var line = fnameescape(getline('.'))
  close
  win_gotoid(prevwinid)
  execute "edit " .. line
enddef
