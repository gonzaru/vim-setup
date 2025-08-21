vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_menu') || !get(g:, 'menu_enabled')
  finish
endif
g:loaded_menu = true

# global variables
if !exists('g:menu_add_menu_extra')
  g:menu_add_menu_extra = false
endif

# autoload
import autoload '../autoload/menu.vim'

# define mappings
nnoremap <silent> <script> <Plug>(menu-language-spell) <ScriptCmd>menu.LanguageSpell()<CR>
nnoremap <silent> <script> <Plug>(menu-misc) <ScriptCmd>menu.Misc()<CR>
nnoremap <silent> <script> <Plug>(menu-menu-add-extra) <ScriptCmd>menu.AddMenuExtra()<CR>
nnoremap <silent> <script> <Plug>(menu-menu-del-extra) <ScriptCmd>menu.DelMenuExtra()<CR>

# set mappings
if get(g:, 'menu_no_mappings') == 0
  if empty(mapcheck("<leader>me", "n"))
    nnoremap <leader>me <Plug>(menu-menu-add-extra)
  endif
  if empty(mapcheck("<leader>mE", "n"))
    nnoremap <leader>mE <Plug>(menu-menu-del-extra)
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
  command! MenuAddExtra execute "normal \<Plug>(menu-menu-add-extra)"
  command! MenuDelExtra execute "normal \<Plug>(menu-menu-del-extra)"
  # TODO: <Plug>?
  command! MenuLanguageSpell menu.LanguageSpell()
  command! MenuMisc menu.Misc()
endif
