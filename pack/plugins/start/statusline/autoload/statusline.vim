vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_statusline') || !get(g:, 'statusline_enabled') || &cp
  finish
endif
g:autoloaded_statusline = 1

# script local variables
export var statusline_full: string

# draw statusline
export def Draw(): string
  return statusline_full
enddef

# checks if it is a valid git repo
def GitValidRepo(dir: string): number
  system("cd " .. dir .. " && git -C . rev-parse 2>/dev/null")
  return v:shell_error == 0 ? 1 : 0
enddef

# show git branch
def GitBranch(mode: string): string
  var branch: string
  var filehead: string
  var filepath = mode == "curfile" ? resolve(expand('%:p')) : getcwd()
  var ftype: string
  var gitroot: string
  var output: list<string>
  # file or directory does not exist
  if !empty(filepath) && empty(getftype(filepath))
    return ''
  endif
  # empty file or directory
  if empty(filepath) && empty(&filetype)
    filepath = resolve(getcwd())
  endif
  ftype = getftype(filepath)
  filehead = filepath
  if ftype == "file"
    filehead = fnamemodify(filepath, ':h')
  endif
  if !isdirectory(filehead)
    return 'DEBUG_UNSUPPORTED_FILE: ' .. filehead
  endif
  gitroot = filehead
  # GitValidRepo(gitroot)
  output = systemlist("cd " .. gitroot .. " && git rev-parse --abbrev-ref HEAD")
  if !v:shell_error && !empty(output)
    branch = output[0]
  endif
  return branch
enddef

# my statusline
export def MyStatusLine(file: string): string
  var cwddirname = fnamemodify(getcwd(), ":~")
  var cwddirnamelist = split(cwddirname, "/")
  var cwddirnametail = fnamemodify(cwddirname, ":t")
  var dirchars: string
  var gitbranchd: string
  var gitbranchf: string
  var numdirslashes = len(cwddirnamelist)
  var shortdirname: string
  var i = 0
  for d in cwddirnamelist
    if i < numdirslashes - 1
      if d[0] == '.'
        dirchars ..= d[0 : 1] .. "/"
      else
        dirchars ..= d[0] .. "/"
      endif
    endif
    ++i
  endfor
  if cwddirname[0] == "/"
    shortdirname = "/" .. dirchars .. cwddirnametail
  else
    shortdirname = dirchars .. cwddirnametail
  endif
  if get(g:, 'statusline_showgitbranch')
    gitbranchf = "{"  .. GitBranch("curfile") .. "}% "
    gitbranchd = "{" .. GitBranch("curdir") .. "}:"
  endif
  statusline_full = gitbranchf .. gitbranchd .. shortdirname .. '$'
  return statusline_full
enddef
