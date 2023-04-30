vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_esckey') || !get(g:, 'esckey_enabled') || &cp
  finish
endif
g:autoloaded_esckey = 1

# enable key as escape
export def Enable()
  # <C-l> goes to normal mode in evim/insertmode
  # <C-l> adds one character from the current match in insert completion
  if tolower(g:esckey_key) == "<c-l>"
    inoremap <expr> <C-l> (pumvisible() <bar><bar> &insertmode) ? '<C-l>' : '<ESC>'
  else
    execute "inoremap " .. g:esckey_key .. " <Esc>"
  endif
  execute "vnoremap " .. g:esckey_key .. " <Esc>"
  execute "cnoremap " .. g:esckey_key .. " <Esc>"
enddef

# disable key as escape
export def Disable()
  if !empty(mapcheck(g:esckey_key, "i"))
    execute "iunmap " .. g:esckey_key
  endif
  if !empty(mapcheck(g:esckey_key, "v"))
    execute "vunmap " .. g:esckey_key
  endif
  if !empty(mapcheck(g:esckey_key, "c"))
    execute "cunmap " .. g:esckey_key
  endif
enddef

# toggle key as escape
export def Toggle()
  if g:esckey_enabled
    Disable()
  else
    Enable()
  endif
  g:esckey_enabled = !get(g:, "esckey_enabled")
  v:statusmsg = "esckey=" .. g:esckey_enabled
enddef
