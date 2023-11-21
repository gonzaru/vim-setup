vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_complementum') || !get(g:, 'complementum_enabled') || &cp
  finish
endif
g:autoloaded_complementum = 1

# allowed file types
const ALLOWED_TYPES = ["go"]

# prints the error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# insert autocompletion
export def InsertAutoComplete(lang: string, nr: any): string
  var str: string
  if index(ALLOWED_TYPES, lang) == -1
    EchoErrorMsg("Error: running filetype '" .. &filetype .. "' is not supported")
    return ""
  endif
  if lang == "go"
    str = GoInsertAutoComplete(lang, nr)
  else
    str = (typename(nr) == "number") ? nr2char(nr) : nr
  endif
  return str
enddef

# Go (golang) insert autocompletion
export def GoInsertAutoComplete(lang: string, nr: any): string
  var curcol: number
  var curline: string
  var key: dict<number>
  # exception: backspace is returned by getchar() with the value of <80>kb
  if typename(nr) == "string" && strtrans(nr) == '<80>kb'
    return "\<BACKSPACE>"
  endif
  # exception: control + space is returned by getchar() with the value of <80><ff>X
  if typename(nr) == "string" && strtrans(nr) == '<80><ff>X'
    return "\<SPACE>"
  endif
  # go plugins (vim-go/govim) must be enabled
  if lang != "go" || index(["go#complete#Complete", "GOVIM_internal_Complete"], &omnifunc) == -1
    return (typename(nr) == "number") ? nr2char(nr) : nr
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
  return (typename(nr) == "number") ? nr2char(nr) : nr
enddef
