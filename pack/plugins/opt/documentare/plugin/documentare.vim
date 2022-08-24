vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_documentare') || !get(g:, 'documentare_enabled') || &cp
  finish
endif
g:loaded_documentare = 1

# autoload
import autoload '../autoload/documentare.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(documentare-doc) <ScriptCmd>documentare.Doc(&filetype)<CR>
nnoremap <silent> <unique> <script> <Plug>(documentare-close) <ScriptCmd>documentare.Close()<CR>

# set mappings
if get(g:, 'documentare_no_mappings') == 0
  # if empty(mapcheck("<leader>K", "n"))
  #   nnoremap <leader>K <Plug>(documentare-doc)
  # endif
endif

# set commands
if get(g:, 'documentare_no_commands') == 0
  command! DocumentareDoc documentare.Doc(&filetype)
  command! DocumentareClose documentare.Close()
endif
