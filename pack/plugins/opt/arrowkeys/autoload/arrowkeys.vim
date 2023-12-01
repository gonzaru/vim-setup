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
  nnoremap <up> <up>
  nnoremap <down> <down>
  nnoremap <left> <left>
  nnoremap <right> <right>
  inoremap <up> <up>
  inoremap <down> <down>
  inoremap <left> <left>
  inoremap <right> <right>
  vnoremap <up> <up>
  vnoremap <down> <down>
  vnoremap <left> <left>
  vnoremap <right> <right>
enddef

# disable arrow keys
export def Disable()
  nnoremap <up> <nop>
  nnoremap <down> <nop>
  nnoremap <left> <nop>
  nnoremap <right> <nop>
  inoremap <up> <nop>
  inoremap <down> <nop>
  inoremap <left> <nop>
  inoremap <right> <nop>
  vnoremap <up> <nop>
  vnoremap <down> <nop>
  vnoremap <left> <nop>
  vnoremap <right> <nop>
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
