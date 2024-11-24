vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_menu') || !get(g:, 'menu_enabled')
  finish
endif
g:loaded_menu = true

# global variables
# TODO

# autoload
import autoload '../autoload/menu.vim'

# define mappings
nnoremap <silent> <script> <Plug>(menu-language-spell) <ScriptCmd>menu.LanguageSpell()<CR>
nnoremap <silent> <script> <Plug>(menu-misc) <ScriptCmd>menu.Misc()<CR>
nnoremap <silent> <script> <Plug>(menu-menu-extra) <ScriptCmd>menu.MenuExtra()<CR>

# set mappings
if get(g:, 'menu_no_mappings') == 0
  if empty(mapcheck("<leader>me", "n"))
    nnoremap <leader>me <Plug>(menu-menu-extra)
  endif
  if empty(mapcheck("<leader>mm", "n"))
    nnoremap <leader>mm <Plug>(menu-misc)
  endif
  if empty(mapcheck("<leader>ms", "n"))
    nnoremap <leader>ms <Plug>(menu-language-spell)
  endif
endif

# set commands
if get(g:, 'menu_no_commands') == 0
  command! MenuExtra execute "normal \<Plug>(menu-menu-extra)"
  # TODO: <Plug>?
  command! MenuLanguageSpell menu.LanguageSpell()
  command! MenuMisc menu.Misc()
endif
