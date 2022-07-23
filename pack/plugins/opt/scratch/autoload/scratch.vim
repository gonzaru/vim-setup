vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_scratch') || !get(g:, 'scratch_enabled') || &cp
  finish
endif
g:autoloaded_scratch = 1

# scratch buffer
export def Buffer()
  var curbufn = winbufnr(winnr())
  var scnum = 0
  var match = 0
  for b in getbufinfo()
    # :help special-buffers
    if empty(b.name)
      && getbufvar(b.bufnr, '&buftype') == 'nofile'
      && getbufvar(b.bufnr, '&bufhidden') == 'hide'
      && !getbufvar(b.bufnr, '&swapfile')
      && !getbufvar(b.bufnr, '&buflisted')
      scnum = b.bufnr
      match = 1
      break
    endif
  endfor
  if match
    if curbufn == scnum
      # return to previous buffer if we are in the scratch
      if !empty(getreg('#'))
        execute "b #"
      endif
    else
      execute "b " .. scnum
    endif
  else
    enew
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
  endif
enddef

# scratch terminal
export def Terminal()
  var curbufn = winbufnr(winnr())
  var scnum = 0
  var match = 0
  for b in getbufinfo()
    if b.name =~ '\[ScratchTerminal\]'
      && getbufvar(b.bufnr, '&buftype') == 'terminal'
      && term_getstatus(b.bufnr) == 'running,normal'
      && getbufvar(b.bufnr, '&bufhidden') == 'hide'
      && !getbufvar(b.bufnr, '&swapfile')
      && !getbufvar(b.bufnr, '&buflisted')
      scnum = b.bufnr
      match = 1
      break
    endif
  endfor
  if match
    if curbufn == scnum
      # return to previous buffer if we are in the scratch
      if !empty(getreg('#')) && getreg('#') !~ '\[ScratchTerminal\]'
        execute "b #"
      endif
    else
      execute "b " .. scnum
    endif
  else
    terminal ++curwin ++noclose ++norestore
    keepalt file [ScratchTerminal]
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
  endif
enddef
