vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_pyvenv') || !get(g:, 'pyvenv_enabled')
  finish
endif
g:loaded_pyvenv = true

# TODO
# global variables
# if !exists('g:pyvenv_default_file')
#   g:pyvenv_default_file = $MYVIMDIR .. 'pyvenvs'
# endif
if !exists('g:pyvenv_lsp_restart')
  g:pyvenv_lsp_restart = true
endif

# autoload
import autoload '../autoload/pyvenv.vim'

# TODO: multiple virtual env support

# define mappings
# nnoremap <silent> <script> <Plug>(pyvenv-activate) <ScriptCmd>pyvenv.Activate(<f-args>)<CR>
 nnoremap <silent> <script> <Plug>(pyvenv-deactivate) <ScriptCmd>pyvenv.Deactivate()<CR>
 nnoremap <silent> <script> <Plug>(pyvenv-list) <ScriptCmd>pyvenv.List()<CR>

# set mappings
# TODO

# set commands
if !get(g:, 'pyvenv_no_commands')
  # command! PyVenvActivate -nargs -compelte=file execute "normal \<Plug>(pyvenv-activate)"
  command! -nargs=1 -complete=file PyVenvActivate pyvenv.Activate(<f-args>)
  command! PyVenvDeactivate execute "normal \<Plug>(pyvenv-deactivate)"
  command! PyVenvList execute "normal \<Plug>(pyvenv-list)"
endif
