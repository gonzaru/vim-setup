vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_documentare') || !get(g:, 'documentare_enabled') || &cp
  finish
endif
g:autoloaded_documentare = 1

# script local variables
const DOCUMENTARE_BUFFER_NAME = "documentare_" .. strftime('%Y%m%d%H%M%S', localtime())

# allowed doc file types
const DOCUMENTARE_ALLOWED_TYPES = ["python", "go"]

# prints error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# prints warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom msg
    echohl None
  endif
enddef

# gets Documentare buffer window id
def GetDocBufWinId(): number
  return bufexists(DOCUMENTARE_BUFFER_NAME) ? bufwinid(DOCUMENTARE_BUFFER_NAME) : -1
enddef

# close documentation window
export def Close()
  var bid = GetDocBufWinId()
  if bid > 0
    win_execute(bid, "bw")
  endif
enddef

# documentation Python
def DocPython(word: string)
  appendbufline('%', 0, systemlist("python3 -m pydoc " .. word))
  deletebufline('%', '$')
  cursor(1, 1)
  if getline(1) =~ '^No Python documentation found for '
    bw
    EchoWarningMsg("Warning: no " .. &filetype .. " documentation found for " .. word)
  endif
enddef

# documentation Go
def DocGo(word: string)
  appendbufline('%', 0, systemlist("go doc " .. word))
  deletebufline('%', '$')
  cursor(1, 1)
  if getline('.') =~ '^doc: no symbol \|^doc: no buildable Go source files in '
    bw
    EchoWarningMsg("Warning: no " .. &filetype .. " documentation found for " .. word)
  endif
enddef

# documentation setup window
def DocSetupWindow()
  var bid = GetDocBufWinId()
  if bid > 0
    win_gotoid(bid)
  elseif bufexists(DOCUMENTARE_BUFFER_NAME) && getbufinfo(DOCUMENTARE_BUFFER_NAME)[0].hidden
    execute "topleft split " .. DOCUMENTARE_BUFFER_NAME
  else
    new
    silent execute "file " .. DOCUMENTARE_BUFFER_NAME
    setlocal buftype=nowrite
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
  endif
enddef

# documentation by language
export def Doc(type: string): void
  var cword: string
  var word: string
  if index(DOCUMENTARE_ALLOWED_TYPES, &filetype) == -1
    EchoErrorMsg("Error: running filetype '" .. &filetype .. "' is not supported")
    return
  endif
  # TODO:
  # if win_getid() == GetDocBufWinId()
  #   EchoWarningMsg("Warning: already using the same window " .. DOCUMENTARE_BUFFER_NAME)
  #   return
  # endif
  cword = expand("<cWORD>")
  if empty(cword) || index(["(", ")", "()"], cword) >= 0
    EchoErrorMsg("Error: word is empty or invalid")
    return
  endif
  word = shellescape(trim(split(cword, "(")[0], '"'))
  if empty(word)
    EchoErrorMsg("Error: word is empty")
    return
  endif
  DocSetupWindow()
  if type == "python"
    DocPython(word)
  elseif type == "go"
    DocGo(word)
  endif
enddef
