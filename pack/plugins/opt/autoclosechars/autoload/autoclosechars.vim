vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_autoeclosechars') || !get(g:, 'autoclosechars_enabled') || &cp
  finish
endif
g:autoloaded_autoclosechars = 1

# automatic close of chars [,(,[
export def Close(mode: string, nr: any): string
  var line = getline('.')
  var key: dict<number>
  # exception: backspace is returned by getchar() with the value of <80>kb
  if typename(nr) == "string" && strtrans(nr) == '<80>kb'
    return "\<BACKSPACE>"
  endif
  if !get(g:, "autoclosechars_enabled")
    return nr2char(nr)
  endif
  key = {'backspace': 8, 'tab': 9, 'enter': 13, 'quote': 34, 'apostrophe': 39}
  if mode == "braceleft"
    if nr == key['enter']
      return "\<CR>}\<ESC>O"
    elseif nr == key['tab']
      return "}\<left>"
    endif
  endif
  if mode == "parenleft"
    if nr == key['enter']
      return "\<CR>)\<ESC>O"
    elseif nr == key['tab'] || nr == key['quote']
      return "\"\")\<left>\<left>"
    elseif nr == key['apostrophe']
      return "'')\<left>\<left>"
    endif
  endif
  if mode == "bracketleft"
    if nr == key['enter']
      return "\<CR>]\<ESC>O"
    elseif nr == key['tab'] || nr == key['quote']
      return "\"\"]\<left>\<left>"
    elseif nr == key['apostrophe']
      return "'']\<left>\<left>"
    endif
  endif
  return nr2char(nr)
enddef

# toggle automatic close of chars
export def Toggle()
  g:autoclosechars_enabled = !get(g:, "autoclosechars_enabled")
  v:statusmsg = "autoclosechars=" .. g:autoclosechars_enabled
enddef
