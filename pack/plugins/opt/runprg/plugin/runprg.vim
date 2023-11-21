vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_runprg') || !get(g:, 'runprg_enabled') || &cp
  finish
endif
g:loaded_runprg = 1

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
nnoremap <silent> <unique> <script> <Plug>(runprg-laststatus) <ScriptCmd>runprg.Run(&filetype, expand('%:p'))<CR>
nnoremap <silent> <unique> <script> <Plug>(runprg-window) <ScriptCmd>runprg.RunWindow(&filetype, expand('%:p'))<CR>
nnoremap <silent> <unique> <script> <Plug>(runprg-close) <ScriptCmd>runprg.Close()<CR>

# set mappings
if get(g:, 'runprg_no_mappings') == 0
  if empty(mapcheck("<leader>ru", "n"))
    nnoremap <leader>ru <Plug>(runprg-laststatus)
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
  command! Run runprg.Run(&filetype, expand('%:p'))
  command! RunWindow runprg.RunWindow(&filetype, expand('%:p'))
  command! RunClose runprg.Close()
endif
