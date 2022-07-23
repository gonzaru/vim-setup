vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_arrowkeys') || !get(g:, 'arrowkeys_enabled') || &cp
  finish
endif
g:loaded_arrowkeys = 1

# autoload
import autoload '../autoload/arrowkeys.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(arrowkeys-enable) <ScriptCmd>arrowkeys.Enable()<CR>
nnoremap <silent> <unique> <script> <Plug>(arrowkeys-disable) <ScriptCmd>arrowkeys.Disable()<CR>

# set mappings
if get(g:, 'arrowkeys_no_mappings') == 0
  if empty(mapcheck("<leader>ae", "n"))
    nnoremap <leader>ae <Plug>(arrowkeys-enable)
  endif
  if empty(mapcheck("<leader>ad", "n"))
    nnoremap <leader>ad <Plug>(arrowkeys-disable)
  endif
  command! ArrowKeysEnable arrowkeys.Enable()
  command! ArrowKeysDisable arrowkeys.Disable()
  command! ArrowKeysToggle arrowkeys.Toggle()
endif
