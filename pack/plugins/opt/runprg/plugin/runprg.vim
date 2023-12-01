vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_runprg') || !get(g:, 'runprg_enabled')
  finish
endif
g:loaded_runprg = true

# global variables
if !exists('g:runprg_sh_command')
  g:runprg_sh_command = ['sh']
endif
if !exists('g:runprg_bash_command')
  g:runprg_bash_command = ['bash']
endif
if !exists('g:runprg_python_command')
  g:runprg_python_command = ['python3']
endif
if !exists('g:runprg_go_command')
  g:runprg_go_command = ['go run']
endif

# autoload
import autoload '../autoload/runprg.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(runprg-run) <ScriptCmd>runprg.Run(&filetype, expand('%:p'))<CR>
nnoremap <silent> <unique> <script> <Plug>(runprg-window) <ScriptCmd>runprg.RunWindow(&filetype, expand('%:p'))<CR>
nnoremap <silent> <unique> <script> <Plug>(runprg-close) <ScriptCmd>runprg.Close()<CR>

# set mappings
if get(g:, 'runprg_no_mappings') == 0
  if empty(mapcheck("<leader>ru", "n"))
    nnoremap <leader>ru <Plug>(runprg-run)
  endif
  if empty(mapcheck("<leader>rU", "n"))
    nnoremap <leader>rU <Plug>(runprg-window)
  endif
  if empty(mapcheck("<leader>RU", "n"))
    nnoremap <leader>RU <Plug>(runprg-close)
  endif
endif

# set commands
if get(g:, 'runprg_no_commands') == 0
  command! Run execute "normal \<Plug>(runprg-run)"
  command! RunWindow execute "normal \<Plug>(runprg-window)"
  command! RunClose execute "normal \<Plug>(runprg-close)"
endif
