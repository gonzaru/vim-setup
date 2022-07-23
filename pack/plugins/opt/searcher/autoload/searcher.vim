vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_searcher') || !get(g:, 'searcher_enabled') || &cp
  finish
endif
g:autoloaded_searcher = 1

# find files
export def Find(args: string, mode: string): void
  var cmd: string
  var range_args: list<string>
  var list_args = split(args, " ")
  var num_args = len(list_args)
  var first_arg: string
  var last_arg = list_args[num_args - 1]
  var findprg = 'fd --type f --follow --no-ignore --strip-cwd-prefix --color=never'
  var ignore_case = false
  var idx = index(list_args, "-i")
  if idx >= 0
    ignore_case = true
    remove(list_args, idx)
    --num_args
  endif
  first_arg = fnamemodify(list_args[0], ":p")
  findprg ..= ignore_case ? ' --ignore-case' : ' --case-sensitive'
  if num_args >= 2 && getftype(first_arg) == "dir"
    findprg ..= ' --absolute-path --base-directory'
    cmd = findprg .. ' ' .. shellescape(first_arg) .. " " .. shellescape(last_arg) .. " | xargs file | sed 's/:/:1:/'"
  else
    cmd = findprg .. ' ' .. shellescape(join(list_args, " ")) .. " | xargs file | sed 's/:/:1:/'"
  endif
  if mode == "quickfix"
    cgetexp system(cmd)
    cwindow
  elseif mode == "locationlist"
    lgetexp system(cmd)
    lwindow
  endif
enddef

# grep searching and find matches
export def Grep(args: string, mode: string): void
  var cmd: string
  var range_args: list<string>
  var list_args = split(args, " ")
  var num_args = len(list_args)
  var last_arg = fnamemodify(list_args[num_args - 1], ":p")
  var grepprg = 'rg --vimgrep --line-number --no-heading --color=never'
  var ignore_case = false
  var idx = index(list_args, "-i")
  if idx >= 0
    ignore_case = true
    remove(list_args, idx)
    --num_args
  endif
  grepprg ..= ignore_case ? ' --ignore-case' : ' --smart-case'
  if num_args >= 2 && (index(['file', 'dir'], getftype(last_arg)) >= 0 || last_arg =~ '*')
    range_args = list_args[0 : num_args - 2]
    cmd = grepprg .. ' ' .. shellescape(join(range_args, " ")) .. " " .. shellescape(last_arg)
  else
    cmd = grepprg .. ' ' .. shellescape(join(list_args, " "))
  endif
  if mode == "quickfix"
    cgetexp system(cmd)
    cwindow
  elseif mode == "locationlist"
    lgetexp system(cmd)
    lwindow
  endif
enddef
