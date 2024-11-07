vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_arrowkeys') || !get(g:, 'arrowkeys_enabled')
  finish
endif
g:autoloaded_arrowkeys = true

# enable arrow keys
export def Enable()
  nnoremap <Up> <Up>
  nnoremap <Down> <Down>
  nnoremap <Left> <Left>
  nnoremap <Right> <Right>
  inoremap <Up> <Up>
  inoremap <Down> <Down>
  inoremap <Left> <Left>
  inoremap <Right> <Right>
  vnoremap <Up> <Up>
  vnoremap <Down> <Down>
  vnoremap <Left> <Left>
  vnoremap <Right> <Right>
enddef

# disable arrow keys
export def Disable()
  nnoremap <Up> <Nop>
  nnoremap <Down> <Nop>
  nnoremap <Left> <Nop>
  nnoremap <Right> <Nop>
  if g:arrowkeys_mode == 'hard'
    inoremap <Up> <Nop>
    inoremap <Down> <Nop>
    inoremap <Left> <Nop>
    inoremap <Right> <Nop>
    vnoremap <Up> <Nop>
    vnoremap <Down> <Nop>
    vnoremap <Left> <Nop>
    vnoremap <Right> <Nop>
  endif
enddef

# toggle arrow keys
export def Toggle()
  if g:arrowkeys_enabled
    Disable()
  else
    Enable()
  endif
  g:arrowkeys_enabled = !g:arrowkeys_enabled
  v:statusmsg = $"arrowkeys={g:arrowkeys_enabled}"
enddef
