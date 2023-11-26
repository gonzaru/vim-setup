vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_autoeclosechars') || !get(g:, 'autoclosechars_enabled')
  finish
endif
g:autoloaded_autoclosechars = true

# automatic close of chars [,(,[
export def Close(mode: string, nr: any): string
  var action: string
  const key = {
    'backspace': 7,
    'tab': 9,
    'enter': 13,
    'quote': 34,
    'apostrophe': 39
  }
  # exception: backspace is returned by getchar() with the value of <80>kb
  if typename(nr) == "string" && strtrans(nr) == '<80>kb'
    return "\<BACKSPACE>"
  endif
  if !g:autoclosechars_enabled
    return nr2char(nr)
  endif
  if mode == "braceleft"
    if nr == key['enter']
      action = "\<CR>}\<ESC>O"
    elseif nr == key['tab']
      action = "}\<left>"
    endif
  elseif mode == "parenleft"
    if nr == key['enter']
      action = "\<CR>)\<ESC>O"
    elseif nr == key['tab'] || nr == key['quote']
      action = "\"\")\<left>\<left>"
    elseif nr == key['apostrophe']
      action = "'')\<left>\<left>"
    endif
  elseif mode == "bracketleft"
    if nr == key['enter']
      action = "\<CR>]\<ESC>O"
    elseif nr == key['tab'] || nr == key['quote']
      action = "\"\"]\<left>\<left>"
    elseif nr == key['apostrophe']
      action = "'']\<left>\<left>"
    endif
  else
    action = nr2char(nr)
  endif
  return action
enddef

# toggle automatic close of chars
export def Toggle()
  g:autoclosechars_enabled = !g:autoclosechars_enabled
  v:statusmsg = "autoclosechars=" .. g:autoclosechars_enabled
enddef
