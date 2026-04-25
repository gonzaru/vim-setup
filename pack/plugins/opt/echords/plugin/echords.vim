vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_echords') || !get(g:, 'echords_enabled')
  finish
endif
g:loaded_echords = true

# global variables
if !exists('g:echords_auto_enable')
  g:echords_auto_enable = false
endif
if !exists('g:echords_extra_mappings')
  g:echords_extra_mappings = false
endif

# autoload
import autoload '../autoload/echords.vim'

# enable
if get(g:, 'echords_auto_enable')
  echords.Enable()
endif

# define mappings
nnoremap <silent> <script> <Plug>(echords-enable) <ScriptCmd>echords.Enable()<CR>
nnoremap <silent> <script> <Plug>(echords-disable) <ScriptCmd>echords.Disable()<CR>
nnoremap <silent> <script> <Plug>(echords-toggle) <ScriptCmd>echords.Toggle()<CR>

# set mappings
if !get(g:, 'echords_no_mappings')
  if empty(mapcheck("<leader>ze", "n"))
    nnoremap <leader>ze <Plug>(echords-enable)
  endif
  if empty(mapcheck("<leader>zd", "n"))
    nnoremap <leader>zd <Plug>(echords-disable)
  endif
  if empty(mapcheck("<leader>zt", "n"))
    nnoremap <leader>zt <Plug>(echords-toggle)
  endif
endif

# set commands
if !get(g:, 'echords_no_commands')
  command! EchordsEnable execute "normal \<Plug>(echords-enable)"
  command! EchordsDisable execute "normal \<Plug>(echords-disable)"
  command! EchordsToggle execute "normal \<Plug>(echords-toggle)"
endif
