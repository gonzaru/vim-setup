vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_autowrite') || !get(g:, 'autowrite_enabled')
  finish
endif
g:autoloaded_autowrite = true

# enable autowrite keys
export def Enable()
  g:autowrite_enabled = true
enddef

# disable autowrite keys
export def Disable()
  g:autowrite_enabled = false
enddef

# toggle autowrite keys
export def Toggle()
  g:autowrite_enabled = !g:autowrite_enabled
  v:statusmsg = $"autowrite={g:autowrite_enabled}"
enddef
