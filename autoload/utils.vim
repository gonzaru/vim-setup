vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_utils') || !get(g:, 'utils_enabled')
  finish
endif
g:autoloaded_utils = true

# tells if the buffer is empty
export def BufferIsEmpty(): bool
  return line('$') == 1 && empty(getline(1))
enddef

# checks if the directory is empty
export def DirIsEmpty(path: string): bool
  var hidden: list<any>
  var nohidden: list<any>
  if getftype(path) != "dir"
    EchoErrorMsg($"Error: '{path}' is not a directory or does not exist")
    return false
  endif
  nohidden = globpath(path, "*", 0, 1)
  hidden = globpath(path, ".*", 0, 1)[2 :]
  return !len(extend(nohidden, hidden))
enddef

# to consume the space typed after an abbreviation
export def Eatchar(pat: string): string
  var c = nr2char(getchar(0))
  return (c =~ pat) ? '' : c
enddef

# prints the error message and saves the message in the message-history
export def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# prints the warning message and saves the message in the message-history
export def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom msg
    echohl None
  endif
enddef

# returns an indicator that identifies a file (*/=@|)
export def FileIndicator(file: string): string
  var ftype = getftype(file)
  var symbol: string
  if ftype == "dir"
    symbol = "/"
  elseif ftype == "file" && executable(file)
    symbol = "*"
  elseif ftype == "link"
    symbol = "@"
  elseif ftype == "fifo"
    symbol = "|"
  elseif ftype == "socket"
    symbol = "="
  else
    symbol = ""
  endif
  return symbol
enddef

# checks if the file is empty
export def FileIsEmpty(file: string): bool
  if getftype(file) != "file"
    EchoErrorMsg($"Error: '{file}' is not a normal file")
    return true
  endif
  if !filereadable(file)
    EchoErrorMsg($"Error: '{file}' is not a readable file")
    return true
  endif
  return !getfsize(file)
enddef

# detects if the shell is sh or bash using shebang
export def SHShellType(): string
  if &filetype != "sh"
    EchoErrorMsg($"Error: filetype '{&filetype}' is not supported")
    return ''
  endif
  return getline(1) =~ "bash" ? "bash" : "sh"
enddef
