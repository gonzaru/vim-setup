vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_autoeclosechars') || !get(g:, 'autoclosechars_enabled')
  finish
endif
g:loaded_autoclosechars = true

# autoload
import autoload '../autoload/autoclosechars.vim'

# define mappings
nnoremap <silent> <script> <Plug>(autoclosechars-toggle) <ScriptCmd>autoclosechars.Toggle()<CR>
inoremap <silent> <script> <Plug>(autoclosechars-braceleft)
  \ <C-r>=<SID>autoclosechars.Close("braceleft", getchar())<CR>
inoremap <silent> <script> <Plug>(autoclosechars-parenleft)
  \ <C-r>=<SID>autoclosechars.Close("parenleft", getchar())<CR>
inoremap <silent> <script> <Plug>(autoclosechars-bracketleft)
  \ <C-r>=<SID>autoclosechars.Close("bracketleft", getchar())<CR>

# set mappings
if get(g:, 'autoclosechars_no_mappings') == 0
  if empty(mapcheck("[", "i"))
    inoremap [ [<Plug>(autoclosechars-bracketleft)
  endif
  if empty(mapcheck("(", "i"))
    inoremap ( (<Plug>(autoclosechars-parenleft)
  endif
  if empty(mapcheck("{", "i"))
    inoremap { {<Plug>(autoclosechars-braceleft)
  endif
  if empty(mapcheck("<leader>tga", "n"))
    nnoremap <leader>tga <Plug>(autoclosechars-toggle):echo v:statusmsg<CR>
  endif
endif

# set commands
if get(g:, 'autoclosechars_no_commands') == 0
  command! AutoCloseCharsEnable g:autoclosechars_enabled = true
  command! AutoCloseCharsDisable g:autoclosechars_enabled = false
  command! AutoCloseCharsToggle execute "normal \<Plug>(autoclosechars-toggle)"
endif
