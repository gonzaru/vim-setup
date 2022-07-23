vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_bufferonly') || !get(g:, 'bufferonly_enabled') || &cp
  finish
endif
g:autoloaded_bufferonly = 1

# remove all buffers except the current one
export def RemoveAllExceptCurrent(mode: string)
  var bufinfo: list<dict<any>>
  var curbufid = winbufnr(winnr())
  if mode == 'delete' || mode == 'wipe'
    bufinfo = getbufinfo({'buflisted': 1})
  elseif mode == 'wipe!'
    bufinfo = getbufinfo()
  endif
  for b in bufinfo
    if b.bufnr == curbufid
      continue
    endif
    if getbufvar(b.bufnr, '&buftype') == 'terminal' && term_getstatus(b.bufnr) == 'running,normal'
      if mode == "delete"
        execute "bd! " .. b.bufnr
      elseif mode == "wipe" || mode == "wipe!"
        execute "bw! " .. b.bufnr
      endif
    else
      if mode == "delete"
        execute "bd " .. b.bufnr
      elseif mode == "wipe" || mode == "wipe!"
        execute "bw " .. b.bufnr
      endif
    endif
  endfor
enddef
