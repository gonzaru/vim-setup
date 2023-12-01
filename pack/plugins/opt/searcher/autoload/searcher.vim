vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_searcher') || !get(g:, 'searcher_enabled')
  finish
endif
g:autoloaded_searcher = true

# searcher commands
const COMMANDS = {
  'findprg': {
    'command': join(g:searcher_findprg_command)
  },
  'grepprg': {
    'command': join(g:searcher_grepprg_command)
  }
}

# find files
export def Find(args: string, mode: string): void
  var cmd: string
  # var rangeargs: list<string>
  var listargs = split(args, " ")
  var numargs = len(listargs)
  var firstarg: string
  var lastarg = listargs[numargs - 1]
  var findprg = COMMANDS['findprg']['command']
  var ignorecase = false
  var idx = index(listargs, "-i")
  if idx >= 0
    ignorecase = true
    remove(listargs, idx)
    --numargs
  endif
  firstarg = fnamemodify(listargs[0], ":p")
  findprg ..= ' ' .. (
    ignorecase ? join(g:searcher_findprg_insensitive) : join(g:searcher_findprg_sensitive)
  )
  if numargs >= 2 && getftype(firstarg) == "dir"
    findprg ..= ' ' .. join(g:searcher_findprg_directory)
    cmd = findprg .. ' ' .. shellescape(firstarg) .. " " .. shellescape(lastarg) .. " | xargs file | sed 's/:/:1:/'"
  else
    cmd = findprg .. ' ' .. shellescape(join(listargs, " ")) .. " | xargs file | sed 's/:/:1:/'"
  endif
  if mode == "quickfix"
    cgetexp system(cmd)
    cwindow
  elseif mode == "locationlist"
    lgetexp system(cmd)
    lwindow
  endif
  # TODO: use ftplugin?
  if &filetype == "qf"
    setlocal number
  endif
enddef

# grep searching and find matches
export def Grep(args: string, mode: string): void
  var cmd: string
  var rangeargs: list<string>
  var listargs = split(args, " ")
  var numargs = len(listargs)
  var lastarg = fnamemodify(listargs[numargs - 1], ":p")
  var grepprg = COMMANDS['grepprg']['command']
  var ignorecase = false
  var idx = index(listargs, "-i")
  if idx >= 0
    ignorecase = true
    remove(listargs, idx)
    --numargs
  endif
  grepprg ..= ' ' .. (
    ignorecase ? join(g:searcher_grepprg_insensitive) : join(g:searcher_grepprg_sensitive)
  )
  if numargs >= 2 && (index(['file', 'dir'], getftype(lastarg)) >= 0 || lastarg =~ '*')
    rangeargs = listargs[0 : numargs - 2]
    cmd = grepprg .. ' ' .. shellescape(join(rangeargs, " ")) .. " " .. shellescape(lastarg)
  else
    cmd = grepprg .. ' ' .. shellescape(join(listargs, " "))
  endif
  if mode == "quickfix"
    cgetexp system(cmd)
    cwindow
  elseif mode == "locationlist"
    lgetexp system(cmd)
    lwindow
  endif
  # TODO: use ftplugin?
  if &filetype == "qf"
    setlocal number
  endif
enddef
