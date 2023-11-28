vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_scratch') || !get(g:, 'scratch_enabled')
  finish
endif
g:autoloaded_scratch = true

# get the scratch buffer
def GetScratchBufId(): number
  var bid: number
  for b in getbufinfo()
    # :help special-buffers
    if empty(b.name)
      && getbufvar(b.bufnr, '&buftype') == 'nofile'
      && getbufvar(b.bufnr, '&bufhidden') == 'hide'
      && !getbufvar(b.bufnr, '&swapfile')
      && !getbufvar(b.bufnr, '&buflisted')
      bid = b.bufnr
      break
    endif
  endfor
  return bid
enddef

# get the scratch terminal buffer
def GetScratchTerminalBufId(): number
  var bid: number
  for b in getbufinfo()
    if b.name =~ '\[ScratchTerminal\]'
      && getbufvar(b.bufnr, '&buftype') == 'terminal'
      && term_getstatus(b.bufnr) == 'running,normal'
      && getbufvar(b.bufnr, '&bufhidden') == 'hide'
      && !getbufvar(b.bufnr, '&swapfile')
      && !getbufvar(b.bufnr, '&buflisted')
      bid = b.bufnr
      break
    endif
  endfor
  return bid
enddef

# scratch buffer
export def Buffer()
  var bid: number
  bid = GetScratchBufId()
  if bid > 0
    if win_getid() == bufwinid(bid)
      # return to previous buffer if we are in the scratch
      if !empty(getreg('#'))
        execute "b #"
      endif
    else
      execute $"b {bid}"
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
  var bid: number
  bid = GetScratchTerminalBufId()
  if bid > 0
    if win_getid() == bufwinid(bid)
      # return to previous buffer if we are in the scratch
      if !empty(getreg('#')) && getreg('#') !~ '\[ScratchTerminal\]'
        execute "b #"
      endif
    else
      execute $"b {bid}"
    endif
  else
    terminal ++curwin ++noclose ++norestore
    keepalt file [ScratchTerminal]
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
  endif
enddef
