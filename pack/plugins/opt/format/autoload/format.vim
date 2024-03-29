vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_format') || !get(g:, 'format_enabled')
  finish
endif
g:autoloaded_format = true

# allowed file types
const ALLOWED_TYPES = ["sh", "python", "go"]

# format commands
const COMMANDS = {
  'sh': {
    'command': join(g:format_sh_command)
  },
  'bash': {
    'command': join(g:format_bash_command)
  },
  'python': {
    'command': join(g:format_python_command)
  },
  'go': {
    'command': join(g:format_go_command)
  }
}

# prints the error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# format
def Format(lang: string, file: string): void
  var autoread_orig:  bool
  var outmsg: list<string>
  var cmd: string
  var theshell: string
  if lang == "sh"
    theshell = getline(1) =~ "bash" ? "bash" : "sh"
    cmd = COMMANDS[theshell]["command"]
  else
    cmd = COMMANDS[lang]["command"]
  endif
  outmsg = systemlist($"{cmd} {file}")
  if v:shell_error != 0
    EchoErrorMsg($"Error: the command '{cmd}' could not be executed correctly")
    return
  endif
  autoread_orig = &l:autoread
  setlocal autoread
  silent checktime
  &l:autoread = autoread_orig
  if empty(outmsg) || (lang == "python" && index(outmsg, "1 file left unchanged.") >= 0)
    echo $"Info: the file was not modified by cmd: '{cmd}'"
  endif
enddef

# format by language
export def Language(lang: string, file: string): void
  var cmd: string
  if index(ALLOWED_TYPES, lang) == -1
    EchoErrorMsg($"Error: formatting lang '{lang}' is not supported")
    return
  endif
  cmd = COMMANDS[lang]["command"]->split()[0]
  if !executable(cmd)
    EchoErrorMsg($"Error: the command '{cmd}' was not found")
    return
  endif
  Format(lang, file)
enddef
