vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_escbacktrick') || !get(g:, 'escbacktrick_enabled') || &cp
  finish
endif
g:autoloaded_escbacktrick = 1

# enable backstrick as escape
export def Enable()
  nnoremap ` <Esc>
  inoremap ` <Esc>
  vnoremap ` <Esc>
  cnoremap ` <C-c>
enddef

# disable backtrick as escape
export def Disable()
  if !empty(mapcheck("`", "n"))
    nunmap `
  endif
  if !empty(mapcheck("`", "i"))
    iunmap `
  endif
  if !empty(mapcheck("`", "v"))
    vunmap `
  endif
  if !empty(mapcheck("`", "c"))
    cunmap `
  endif
enddef

# toggle backtrick as escape
export def Toggle()
  if g:escbacktrick_enabled
    Disable()
  else
    Enable()
  endif
  g:escbacktrick_enabled = !get(g:, "escbacktrick_enabled")
  v:statusmsg = "escbacktrick=" .. g:escbacktrick_enabled
enddef
