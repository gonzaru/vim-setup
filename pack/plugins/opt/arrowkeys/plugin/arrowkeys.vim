vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_arrowkeys') || !get(g:, 'arrowkeys_enabled')
  finish
endif
g:loaded_arrowkeys = true

# autoload
import autoload '../autoload/arrowkeys.vim'

# define mappings
nnoremap <silent> <script> <Plug>(arrowkeys-enable) <ScriptCmd>arrowkeys.Enable()<CR>
nnoremap <silent> <script> <Plug>(arrowkeys-disable) <ScriptCmd>arrowkeys.Disable()<CR>
nnoremap <silent> <script> <Plug>(arrowkeys-toggle) <ScriptCmd>arrowkeys.Toggle()<CR>

# set mappings
if get(g:, 'arrowkeys_no_mappings') == 0
  if empty(mapcheck("<leader>ae", "n"))
    nnoremap <leader>ae <Plug>(arrowkeys-enable)
  endif
  if empty(mapcheck("<leader>ad", "n"))
    nnoremap <leader>ad <Plug>(arrowkeys-disable)
  endif
  if empty(mapcheck("<leader>at", "n"))
    nnoremap <leader>at <Plug>(arrowkeys-toggle)
  endif
endif

# set commands
if get(g:, 'arrowkeys_no_commands') == 0
  command! ArrowKeysEnable execute "normal \<Plug>(arrowkeys-enable)"
  command! ArrowKeysDisable execute "normal \<Plug>(arrowkeys-disable)"
  command! ArrowKeysToggle execute "normal \<Plug>(arrowkeys-toggle)"
endif
