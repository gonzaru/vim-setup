vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_bufferonly') || !get(g:, 'bufferonly_enabled')
  finish
endif
g:loaded_bufferonly = true

# autoload
import autoload '../autoload/bufferonly.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(bufferonly-delete)
  \ <ScriptCmd>bufferonly.RemoveAllExceptCurrent("delete")<CR>
nnoremap <silent> <unique> <script> <Plug>(bufferonly-delete!)
  \ <ScriptCmd>bufferonly.RemoveAllExceptCurrent("delete!")<CR>
nnoremap <silent> <unique> <script> <Plug>(bufferonly-wipe)
  \ <ScriptCmd>bufferonly.RemoveAllExceptCurrent("wipe")<CR>
nnoremap <silent> <unique> <script> <Plug>(bufferonly-wipe!)
  \ <ScriptCmd>bufferonly.RemoveAllExceptCurrent("wipe!")<CR>

# set mappings
if get(g:, 'bufferonly_no_mappings') == 0
  if empty(mapcheck("<leader>bo", "n"))
    nnoremap <leader>bo <Plug>(bufferonly-delete)
  endif
  if empty(mapcheck("<leader>bO", "n"))
    nnoremap <leader>bO <Plug>(bufferonly-delete!)
  endif
  if empty(mapcheck("<leader>Bo", "n"))
    nnoremap <leader>Bo <Plug>(bufferonly-wipe)
  endif
  if empty(mapcheck("<leader>BO", "n"))
    nnoremap <leader>BO <Plug>(bufferonly-wipe!)
  endif
endif

# set commands
if get(g:, 'bufferonly_no_commands') == 0
  command! BufferOnlyDelete execute "normal \<Plug>(bufferonly-delete)"
  command! -bang BufferOnlyDelete execute "normal \<Plug>(bufferonly-delete!)"
  command! BufferOnlyWipe execute "normal \<Plug>(bufferonly-wipe)"
  command! -bang BufferOnlyWipe execute "normal \<Plug>(bufferonly-wipe!)"
endif
