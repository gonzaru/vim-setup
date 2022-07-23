vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_complementum') || !get(g:, 'complementum_enabled') || &cp
  finish
endif
g:autoloaded_complementum = 1

# Go (golang) insert autocompletion
export def GoInsertAutoComplete(nr: any): string
  var curcol: number
  var curline: string
  var key: dict<number>
  # exception: backspace is returned by getchar() with the value of <80>kb
  if typename(nr) == "string" && strtrans(nr) == '<80>kb'
    return "\<BACKSPACE>"
  endif
  if &filetype != "go" || index(["go#complete#Complete", "GOVIM_internal_Complete"], &omnifunc) == -1
    return nr2char(nr)
  endif
  curline = getline('.')
  curcol = col('.')
  key = {'backspace': 8, 'tab': 9, 'enter': 13, 'space': 32}
  if !empty(trim(curline)) && curcol > 1
    # tab or space + previous char [a-zA-Z0-9_]+
    if (nr == key['tab'] || nr == key['space']) && strcharpart(curline[curcol - 3 : ], 0, 1) =~ '\h\|\d'
      return "\<C-X>\<C-O>"
    endif
  endif
  return nr2char(nr)
enddef
