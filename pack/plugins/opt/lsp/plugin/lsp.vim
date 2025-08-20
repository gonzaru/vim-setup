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
nnoremap <silent> <script> <Plug>(lsp-definition) <ScriptCmd>lsp.Definition()<CR>
nnoremap <silent> <script> <Plug>(lsp-hover) <ScriptCmd>lsp.Hover()<CR>
nnoremap <silent> <script> <Plug>(lsp-references) <ScriptCmd>lsp.References()<CR>
nnoremap <silent> <script> <Plug>(lsp-rename) <ScriptCmd>lsp.Rename()<CR>

# set mappings
if get(g:, 'lsp_no_mappings') == 0
  if empty(mapcheck("<leader>gd", "n"))
    nnoremap <leader>gd <Plug>(lsp-definition)
    nnoremap <leader><C-]> <Plug>(lsp-definition)
    nnoremap <leader>gi <Plug>(lsp-hover)
    nnoremap <leader>gs <Plug>(lsp-references)
    nnoremap <leader>gr <Plug>(lsp-rename)
  endif
endif

# set commands
if get(g:, 'lsp_no_commands') == 0
  command! LSPStart execute "normal \<Plug>(lsp-start)"
  command! LSPStop execute "normal \<Plug>(lsp-stop)"
  command! LSPStopAll execute "normal \<Plug>(lsp-stop-all)"
  command! LSPRestart execute "normal \<Plug>(lsp-restart)"
  command! LSPInfo execute "normal \<Plug>(lsp-info)"
  command! LSPEnable execute "normal \<Plug>(lsp-enable)"
  command! LSPDefinition execute "normal \<Plug>(lsp-definition)"
  command! LSPDisable execute "normal \<Plug>(lsp-disable)"
  command! LSPHover execute "normal \<Plug>(lsp-hover)"
  command! LSPReferences execute "normal \<Plug>(lsp-references)"
  command! LSPRename execute "normal \<Plug>(lsp-rename)"
endif
