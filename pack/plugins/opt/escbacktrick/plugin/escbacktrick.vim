vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_escbacktrick') || !get(g:, 'escbacktrick_enabled') || &cp
  finish
endif
g:loaded_escbacktrick = 1

# autoload
import autoload '../autoload/escbacktrick.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(escbacktrick-enable) <ScriptCmd>escbacktrick.Enable()<CR>
nnoremap <silent> <unique> <script> <Plug>(escbacktrick-disable) <ScriptCmd>escbacktrick.Disable()<CR>
nnoremap <silent> <unique> <script> <Plug>(escbacktrick-toggle) <ScriptCmd>escbacktrick.Toggle()<CR>

# set mappings
if get(g:, 'escbacktrick_no_mappings') == 0
  if empty(mapcheck("<leader>`e", "n"))
    nnoremap <leader>`e <Plug>(escbacktrick-enable)
  endif
  if empty(mapcheck("<leader>`d", "n"))
    nnoremap <leader>`d <Plug>(escbacktrick-disable)
  endif
  if empty(mapcheck("<leader>`t", "n"))
    nnoremap <leader>`t <Plug>(escbacktrick-toggle)
  endif
endif

# set commands
if get(g:, 'escbacktrick_no_commands') == 0
  command! EscBacktrickEnable escbacktrick.Enable()
  command! EscBacktrickDisable escbacktrick.Disable()
  command! EscBacktrickToggle escbacktrick.Toggle()
endif
