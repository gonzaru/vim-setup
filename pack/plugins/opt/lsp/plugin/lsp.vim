vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_lsp') || !get(g:, 'lsp_enabled')
  finish
endif
g:loaded_lsp = true

# global variables
g:lsp_allowed_types = ["go", "python", "terraform"]
if !exists('g:lsp_python_auto_imports')
  g:lsp_python_auto_imports = false
endif
if !exists('g:lsp_python_sort_dunders')
  g:lsp_python_sort_dunders = true
endif

# complementum plugin
if !exists('g:lsp_complementum')
  g:lsp_complementum = false
endif

# autoload
import autoload '../autoload/lsp.vim'

# define mappings
nnoremap <silent> <script> <Plug>(lsp-start) <ScriptCmd>lsp.Start()<CR>
nnoremap <silent> <script> <Plug>(lsp-stop) <ScriptCmd>lsp.Stop()<CR>
nnoremap <silent> <script> <Plug>(lsp-stop-all) <ScriptCmd>lsp.StopAll()<CR>
nnoremap <silent> <script> <Plug>(lsp-restart) <ScriptCmd>lsp.Restart()<CR>
nnoremap <silent> <script> <Plug>(lsp-info) <ScriptCmd>lsp.Info()<CR>
nnoremap <silent> <script> <Plug>(lsp-enable) <ScriptCmd>lsp.Enable()<CR>
nnoremap <silent> <script> <Plug>(lsp-disable) <ScriptCmd>lsp.Disable()<CR>

# TODO
# set mappings

# set commands
if get(g:, 'lsp_no_commands') == 0
  command! LSPStart execute "normal \<Plug>(lsp-start)"
  command! LSPStop execute "normal \<Plug>(lsp-stop)"
  command! LSPStopAll execute "normal \<Plug>(lsp-stop-all)"
  command! LSPRestart execute "normal \<Plug>(lsp-restart)"
  command! LSPInfo execute "normal \<Plug>(lsp-info)"
  command! LSPEnable execute "normal \<Plug>(lsp-enable)"
  command! LSPDisable execute "normal \<Plug>(lsp-disable)"
endif
