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

# find files and grep searching
export def Search(...args: list<string>): void
  var cmd: string
  var idx: number
  var kind = args[-2]
  var mode = args[-1]
  var nargs = args
  var prg = COMMANDS[kind]['command']
  var str: string
  if index(nargs, '') >= 0
    throw $"Error: the args '{args}' have empty values"
  endif
  idx = index(nargs, '-i')
  if kind == 'findprg'
    prg ..= ' ' .. (idx >= 0 ? join(g:searcher_findprg_insensitive) : join(g:searcher_findprg_sensitive))
  elseif kind == 'grepprg'
    prg ..= ' ' .. (idx >= 0 ? join(g:searcher_grepprg_insensitive) : join(g:searcher_grepprg_sensitive))
  endif
  remove(nargs, -2, -1)
  if idx >= 0
    nargs[1] = $"'{nargs[1]}'"
    remove(nargs, idx)
  else
    nargs[0] = $"'{nargs[0]}'"
  endif
  nargs[-1] = $"'{fnamemodify(nargs[-1], ":p")}'"
  if kind == 'findprg'
    cmd = prg .. ' ' .. join(nargs) .. ' | tr "\n" "\0" | xargs -0 file | sed "s/:/:1:/"'
  elseif kind == 'grepprg'
    cmd = prg .. ' ' .. join(nargs)
  endif
  Run(cmd, mode)
enddef

# run
def Run(cmd: string, mode: string)
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
