vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_bufferonly') || !get(g:, 'bufferonly_enabled') || &cp
  finish
endif
g:autoloaded_bufferonly = 1

# remove all buffers except the current one
export def RemoveAllExceptCurrent(mode: string): void
  var bufinfo: list<dict<any>>
  var curbufid: number
  if index(['delete', 'wipe', 'wipe!'], mode) == -1
    return
  endif
  if mode == 'delete' || mode == 'wipe'
    bufinfo = getbufinfo({'buflisted': 1})
  elseif mode == 'wipe!'
    bufinfo = getbufinfo()
  endif
  curbufid = bufnr()
  for b in bufinfo
    if b.bufnr == curbufid
      continue
    endif
    if mode == "delete"
      if getbufvar(b.bufnr, '&buftype') == 'terminal' && term_getstatus(b.bufnr) == 'running,normal'
        execute "bd! " .. b.bufnr
      else
        execute "bd " .. b.bufnr
      endif
    elseif mode == "wipe" || mode == "wipe!"
      execute "bw! " .. b.bufnr
    endif
  endfor
enddef
