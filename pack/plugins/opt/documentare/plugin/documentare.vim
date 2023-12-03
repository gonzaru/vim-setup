vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_documentare') || !get(g:, 'documentare_enabled')
  finish
endif
g:loaded_documentare = true

# autoload
import autoload '../autoload/documentare.vim'

# define mappings
nnoremap <silent> <script> <Plug>(documentare-doc) <ScriptCmd>documentare.Doc(&filetype)<CR>
nnoremap <silent> <script> <Plug>(documentare-close) <ScriptCmd>documentare.Close()<CR>

# set mappings
if get(g:, 'documentare_no_mappings') == 0
  if empty(mapcheck("<leader>K", "n"))
    nnoremap <leader>K <Plug>(documentare-doc)
  endif
endif

# set commands
if get(g:, 'documentare_no_commands') == 0
  command! DocumentareDoc execute "normal \<Plug>(documentare-doc)"
  command! DocumentareClose execute "normal \<Plug>(documentare-close)"
endif
