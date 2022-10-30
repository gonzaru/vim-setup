vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_format') || !get(g:, 'format_enabled') || &cp
  finish
endif
g:autoloaded_format = 1

# allowed file types
const FORMAT_ALLOWED_TYPES = ["sh", "python", "go"]

# format by language
const FORMAT_LANGUAGE_COMMAND = {
  'sh': 'shfmt -l -w',
  'python': 'black -S -l 79', # -l 79 for pep8
  'go': 'go fmt'
}

# prints error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# format
def Format(filetype: string, file: string): void
  var cmd = FORMAT_LANGUAGE_COMMAND[filetype]->split(" ")[0]
  var outmsg: list<string>
  outmsg = systemlist(FORMAT_LANGUAGE_COMMAND[filetype] .. " " .. file)
  if v:shell_error != 0
    EchoErrorMsg("Error: command '" .. cmd .. "' failed to execute correctly")
    return
  endif
  checktime
  if empty(outmsg) || (filetype == "python" && index(outmsg, "1 file left unchanged.") >= 0)
    echo "Info: file was not modified (" .. cmd .. ")"
  endif
enddef

# format by language
export def Language(file: string): void
  var cmd: string
  if index(FORMAT_ALLOWED_TYPES, &filetype) == -1
    EchoErrorMsg("Error: formatting filetype '" .. &filetype .. "' is not supported")
    return
  endif
  cmd = FORMAT_LANGUAGE_COMMAND[&filetype]->split(" ")[0]
  if !executable(cmd)
    EchoErrorMsg("Error: command '" .. cmd .. "' not found")
    return
  endif
  Format(&filetype, file)
enddef
