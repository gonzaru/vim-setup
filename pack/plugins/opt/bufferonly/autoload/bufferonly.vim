vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_bufferonly') || !get(g:, 'bufferonly_enabled')
  finish
endif
g:autoloaded_bufferonly = true

# remove all buffers except the current one
export def RemoveAllExceptCurrent(mode: string): void
  var bufinfo: list<dict<any>>
  var count = 0
  var curbufid = bufnr()
  if index(['delete', 'delete!', 'wipe', 'wipe!'], mode) == -1
    return
  endif
  bufinfo = (mode == 'delete' || mode == 'wipe') ? getbufinfo({'buflisted': 1}) : getbufinfo()
  for b in bufinfo
    if b.bufnr == curbufid
      continue
    endif
    if &buftype == 'terminal'
      if mode == 'delete!' || mode == 'wipe!'
        execute $'b{mode} {b.bufnr}'
      endif
    else
      execute $'b{mode} {b.bufnr}'
    endif
    ++count
  endfor
  if count > 0
    echo $"{count} {count == 1 ? 'buffer' : 'buffers'} removed"
  endif
enddef
