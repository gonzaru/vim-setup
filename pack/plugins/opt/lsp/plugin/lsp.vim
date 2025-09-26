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
if !exists('g:lsp_sort_by_sorttext')
  g:lsp_sort_by_sorttext = true
endif
if !exists('g:lsp_rename_confirm')
  g:lsp_rename_confirm = true
endif

# complementum plugin
if !exists('g:lsp_complementum')
  g:lsp_complementum = false
endif

# autoload
import autoload '../autoload/lsp.vim'

# autocmd
augroup lsp_start
  autocmd!
  autocmd FileType go,python,terraform ++once {
    if g:lsp_enabled
      execute "normal \<Plug>(lsp-start)"
    endif
  }
augroup END

# define mappings
nnoremap <silent> <script> <Plug>(lsp-start) <ScriptCmd>lsp.Start()<CR>
nnoremap <silent> <script> <Plug>(lsp-stop) <ScriptCmd>lsp.Stop()<CR>
nnoremap <silent> <script> <Plug>(lsp-stop-all) <ScriptCmd>lsp.StopAll()<CR>
nnoremap <silent> <script> <Plug>(lsp-restart) <ScriptCmd>lsp.Restart()<CR>
nnoremap <silent> <script> <Plug>(lsp-info) <ScriptCmd>lsp.Info()<CR>
nnoremap <silent> <script> <Plug>(lsp-enable) <ScriptCmd>lsp.Enable()<CR>
nnoremap <silent> <script> <Plug>(lsp-disable) <ScriptCmd>lsp.Disable()<CR>
nnoremap <silent> <script> <Plug>(lsp-definition) <ScriptCmd>lsp.Definition()<CR>
nnoremap <silent> <script> <Plug>(lsp-document-symbol) <ScriptCmd>lsp.DocumentSymbol()<CR>
nnoremap <silent> <script> <Plug>(lsp-hover) <ScriptCmd>lsp.Hover()<CR>
nnoremap <silent> <script> <Plug>(lsp-references) <ScriptCmd>lsp.References()<CR>
nnoremap <silent> <script> <Plug>(lsp-rename) <ScriptCmd>lsp.Rename()<CR>
nnoremap <silent> <script> <Plug>(lsp-signature) <ScriptCmd>lsp.Signature()<CR>
nnoremap <silent> <script> <Plug>(lsp-running) <ScriptCmd>lsp.Running()<CR>
nnoremap <silent> <script> <Plug>(lsp-ready) <ScriptCmd>lsp.Ready()<CR>

# set mappings
if get(g:, 'lsp_no_mappings') == 0
  if empty(mapcheck("<leader>gd", "n"))
    nnoremap <leader>gd <Plug>(lsp-definition)
  endif
  if empty(mapcheck("<leader><C-]>", "n"))
    nnoremap <leader><C-]> <Plug>(lsp-definition)
  endif
  if empty(mapcheck("<leader>gi", "n"))
    nnoremap <leader>gi <Plug>(lsp-hover)
  endif
  if empty(mapcheck("<leader>gs", "n"))
    nnoremap <leader>gs <Plug>(lsp-references)
  endif
  if empty(mapcheck("<leader>gS", "n"))
    nnoremap <leader>gS <Plug>(lsp-signature)
  endif
  if empty(mapcheck("<leader>GS", "n"))
    nnoremap <leader>GS <Plug>(lsp-document-symbol)
  endif
  if empty(mapcheck("<leader>gr", "n"))
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
  command! LSPEnable execute "normal \<Plug>(lsp-enable)" | echo v:statusmsg
  command! LSPDisable execute "normal \<Plug>(lsp-disable)" | echo v:statusmsg
  command! LSPDefinition execute "normal \<Plug>(lsp-definition)"
  command! LSPDocumentSymbol execute "normal \<Plug>(lsp-document-symbol)"
  command! LSPHover execute "normal \<Plug>(lsp-hover)"
  command! LSPReferences execute "normal \<Plug>(lsp-references)"
  command! LSPRename execute "normal \<Plug>(lsp-rename)"
  command! LSPSignature execute "normal \<Plug>(lsp-signature)"
  command! LSPRunning execute "normal \<Plug>(lsp-running)"
  command! LSPReady execute "normal \<Plug>(lsp-ready)"
  command! LSPUp {
    execute "normal \<Plug>(lsp-start)"
    execute "normal \<Plug>(lsp-enable)"
  }
  command! LSPDown {
    execute "normal \<Plug>(lsp-stop)"
    execute "normal \<Plug>(lsp-disable)"
  }
  command! LSPDownAll {
    execute "normal \<Plug>(lsp-stop-all)"
    execute "normal \<Plug>(lsp-disable)"
  }
  # complementum plugin
  command! LSPComplementumToggle {
    g:lsp_complementum = !g:lsp_complementum
    echo $'g:lsp_complementum = {g:lsp_complementum}'
  }
endif
