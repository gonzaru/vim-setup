vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_pyvenv') || !get(g:, 'pyvenv_enabled')
  finish
endif
g:autoloaded_pyvenv = true

# prints the error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# activate venv
export def Activate(path: string): void
  var venv = trim(fnamemodify(path, ':p'), '/', 2)
  if !isdirectory(venv)
    EchoErrorMsg($"Error: {venv} is not a valid directory")
    return
  endif

  # TODO: check
  # SetPythonDynamic()

  $VIRTUAL_ENV = venv
  var venv_path =  $VIRTUAL_ENV .. '/bin'
  var path_list = split($PATH, ':')
  filter(path_list, (idx, val) => val != venv_path)
  $PATH = $"{venv_path}:{join(path_list, ':')}"

  var version = split(globpath($VIRTUAL_ENV .. '/lib/', "*", 0, 1)[0], '/')[-1]
  var site_packages = $VIRTUAL_ENV  .. $'/lib/{version}/site-packages'
  if isdirectory(site_packages)
    py3 import sys
    execute "py3 if '" .. site_packages .. "' in sys.path: sys.path.remove('" .. site_packages .. "')"
    execute "py3 sys.path.insert(0, '" .. site_packages .. "')"

    if g:pyvenv_lsp_restart && &filetype == "python" && get(g:, 'lsp_enabled')
      lsp#Restart()
    endif
    echomsg $"activated venv: {fnamemodify(venv, ':~')}"
  else
    EchoErrorMsg($"Error: {site_packages} is not a valid directory")
  endif
enddef

# deactivate venv
export def Deactivate(): void
  var venv = $VIRTUAL_ENV
  if empty(venv)
    echo "no venv is currently active"
    return
  endif

  var venv_path = venv .. '/bin'
  var path_list = split($PATH, ':')
  filter(path_list, (idx, val) => val != venv_path)
  $PATH = join(path_list, ':')

  var lib_dirs = globpath(venv .. '/lib/', "*", 0, 1)
  if len(lib_dirs) > 0
    var version = split(lib_dirs[0], '/')[-1]
    var site_packages = venv .. $'/lib/{version}/site-packages'
    py3 import sys
    execute "py3 if '" .. site_packages .. "' in sys.path: sys.path.remove('" .. site_packages .. "')"
  endif

  $VIRTUAL_ENV = ''
  if g:pyvenv_lsp_restart && &filetype == "python" && get(g:, 'lsp_enabled')
    lsp#Restart()
  endif
  echomsg $"deactivated venv: {fnamemodify(venv, ':~')}"
enddef

# list venv
export def List()
  var venv = $VIRTUAL_ENV
  if empty(venv)
    echo "no venv is currently active"
  else
    echo $"venv: {fnamemodify(venv, ':~')}"
  endif
enddef
