vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_esckey') || !get(g:, 'esckey_enabled') || &cp
  finish
endif
g:loaded_esckey = 1

# global variables
if !exists('g:esckey_key')
  g:esckey_key = "<C-l>"
endif

# autoload
import autoload '../autoload/esckey.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(esckey-enable) <ScriptCmd>esckey.Enable()<CR>
nnoremap <silent> <unique> <script> <Plug>(esckey-disable) <ScriptCmd>esckey.Disable()<CR>
nnoremap <silent> <unique> <script> <Plug>(esckey-toggle) <ScriptCmd>esckey.Toggle()<CR>

# set mappings
if get(g:, 'esckey_no_mappings') == 0
  if empty(mapcheck("<leader>je", "n"))
    nnoremap <leader>je <Plug>(esckey-enable)
  endif
  if empty(mapcheck("<leader>jd", "n"))
    nnoremap <leader>jd <Plug>(esckey-disable)
  endif
  if empty(mapcheck("<leader>jt", "n"))
    nnoremap <leader>jt <Plug>(esckey-toggle)
  endif
endif

# set commands
if get(g:, 'esckey_no_commands') == 0
  command! EscKeyEnable esckey.Enable()
  command! EscKeyDisable esckey.Disable()
  command! EscKeyToggle esckey.Toggle()
endif
