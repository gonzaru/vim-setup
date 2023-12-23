vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_habit') || !get(g:, 'habit_enabled')
  finish
endif
g:autoloaded_habit = true

# enable habit keys
export def Enable()
  nnoremap h h
  nnoremap j j
  nnoremap k k
  nnoremap l l
  nnoremap gj gj
  nnoremap gk gk
  nnoremap - -
  nnoremap + +
enddef

# disable habit keys
export def Disable()
  if g:habit_mode == 'soft' || g:habit_mode == 'hard'
    nnoremap h <Nop>
    nnoremap j <Nop>
    nnoremap k <Nop>
    nnoremap l <Nop>
  endif
  if g:habit_mode == 'hard'
    nnoremap gj <Nop>
    nnoremap gk <Nop>
    nnoremap - <Nop>
    nnoremap + <Nop>
  endif
enddef

# toggle habit keys
export def Toggle()
  if g:habit_enabled
    Disable()
  else
    Enable()
  endif
  g:habit_enabled = !g:habit_enabled
  v:statusmsg = $"habit={g:habit_enabled}"
enddef
