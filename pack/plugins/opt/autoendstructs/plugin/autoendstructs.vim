vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_autoendstructs') || !get(g:, 'autoendstructs_enabled')
  finish
endif
g:loaded_autoendstructs = true

# autoload
import autoload '../autoload/autoendstructs.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(autoendstructs-toggle) <ScriptCmd>autoendstructs.Toggle()<CR>
inoremap <silent> <unique> <script> <Plug>(autoendstructs-end) <C-r>=<SID>autoendstructs.End(&filetype)<CR>

# set mappings
if get(g:, 'autoendstructs_no_mappings') == 0
  if empty(mapcheck("<leader>tge", "n"))
    nnoremap <leader>tge <Plug>(autoendstructs-toggle):echo v:statusmsg<CR>
  endif
endif

# set commands
if get(g:, 'autoendstructs_no_commands') == 0
  command! AutoEndStructsEnable g:autoendstructs_enabled = true
  command! AutoEndStructsDisable g:autoendstructs_enabled = false
  command! AutoEndStructsToggle execute "normal \<Plug>(autoendstructs-toggle)"
endif
