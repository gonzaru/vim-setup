vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_documentare') || !get(g:, 'documentare_enabled')
  finish
endif
g:autoloaded_documentare = true

# script local variables
const BUFFER_NAME = $"documentare:{strcharpart(sha256('documentare'), 0, 8)}"

# allowed doc file types
const ALLOWED_TYPES = ["python", "go"]

# prints the error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# prints the warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom msg
    echohl None
  endif
enddef

# gets the Documentare buffer window id
def GetDocBufWinId(): number
  return bufexists(BUFFER_NAME) ? bufwinid(BUFFER_NAME) : -1
enddef

# close the documentation window
export def Close()
  var bid = GetDocBufWinId()
  if bid > 0
    win_execute(bid, "bw")
  endif
enddef

# documentation Python
def DocPython(word: string)
  appendbufline('%', 0, systemlist($"python3 -m pydoc {word}"))
  deletebufline('%', '$')
  cursor(1, 1)
  if getline(1) =~ '^No Python documentation found for '
    bw
    EchoWarningMsg($"Warning: no {&filetype} documentation found for {word}")
  endif
enddef

# documentation Go
def DocGo(word: string)
  appendbufline('%', 0, systemlist($"go doc {word}"))
  deletebufline('%', '$')
  cursor(1, 1)
  if getline('.') =~ '^doc: no symbol \|^doc: no buildable Go source files in '
    bw
    EchoWarningMsg($"Warning: no {&filetype} documentation found for {word}")
  endif
enddef

# documentation setup window
def DocSetupWindow()
  var bid = GetDocBufWinId()
  if bid > 0
    win_gotoid(bid)
  elseif bufexists(BUFFER_NAME) && getbufinfo(BUFFER_NAME)[0].hidden
    execute $"topleft split {BUFFER_NAME}"
  else
    new
    silent execute $"file {BUFFER_NAME}"
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
  endif
enddef

# documentation by language
export def Doc(type: string): void
  var cword: string
  var word: string
  if index(ALLOWED_TYPES, &filetype) == -1
    EchoErrorMsg($"Error: running filetype '{&filetype}' is not supported")
    return
  endif
  # TODO:
  # if win_getid() == GetDocBufWinId()
  #   EchoWarningMsg($"Warning: already using the same window {BUFFER_NAME}")
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
