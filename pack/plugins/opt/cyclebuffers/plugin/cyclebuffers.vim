vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_cyclebuffers') || !get(g:, 'cyclebuffers_enabled')
  finish
endif
g:loaded_cyclebuffers = true

# autoload
import autoload '../autoload/cyclebuffers.vim'

# define mappings
nnoremap <silent> <script> <Plug>(cyclebuffers-cycle) <ScriptCmd>cyclebuffers.Cycle()<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select) <ScriptCmd>cyclebuffers.SelectBuffer(getline('.'))<CR>

# set mappings
if get(g:, 'cyclebuffers_no_mappings') == 0
  if empty(mapcheck("<leader><Space>", "n"))
    nnoremap <leader><Space> <Plug>(cyclebuffers-cycle)
  endif
endif

# set commands
if get(g:, 'cyclebuffers_no_commands') == 0
  command! CycleBuffers execute "normal \<Plug>(cyclebuffers-cycle)"
endif
