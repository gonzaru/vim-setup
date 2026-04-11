vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_calculator') || !get(g:, 'calculator_enabled')
  finish
endif
g:autoloaded_calculator = true

# script local variables
const BUFFER_NAME = $"calculator_{strcharpart(sha256('calculator'), 0, 8)}"

# close
export def Close()
  var runwinid = bufexists(BUFFER_NAME)
  if runwinid > 0
    win_execute(runwinid, "bw")
  endif
enddef

# run
export def Run()
  Close()
  below new
  silent execute $"file {BUFFER_NAME}"
  setlocal filetype=calculator
  resize 1  # one line only
  setline('.', '=')
  timer_start(0, (_) => feedkeys('A', 'n'))
enddef

# evaluate
export def Evaluate(): void
  var expr = getline('.')
  if expr == '=' || expr == '=?' || empty(trim(expr))
    Close()
    feedkeys("\<Esc>", 'n')
    return
  endif
  try
    expr = substitute(expr, '^=?', '', '')
    expr = substitute(expr, '^=', '', '')
    expr = substitute(expr, '\v([0-9.]+)\s*\^\s*(-?[0-9.]+)', 'pow(\1, \2)', 'g')  # n^n
    expr = substitute(expr, '[-+*/]', ' & ', 'g')
    var res = eval(expr)
    if type(res) == v:t_float && res == trunc(res)
      res = float2nr(res)
    endif
    setline('.', '=' .. res)
  catch
    setline('.', '=?')  # error
  endtry
enddef
