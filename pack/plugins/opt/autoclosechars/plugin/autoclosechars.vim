vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_autoeclosechars') || !get(g:, 'autoclosechars_enabled') || &cp
  finish
endif
g:loaded_autoclosechars = 1

# autoload
import autoload '../autoload/autoclosechars.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(autoclosechars-toggle) <ScriptCmd>autoclosechars.Toggle()<CR>
inoremap <silent> <unique> <script> <Plug>(autoclosechars-braceleft)
  \ <C-r>=<SID>autoclosechars.Close("braceleft", getchar())<CR>
inoremap <silent> <unique> <script> <Plug>(autoclosechars-parenleft)
  \ <C-r>=<SID>autoclosechars.Close("parenleft", getchar())<CR>
inoremap <silent> <unique> <script> <Plug>(autoclosechars-bracketleft)
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
  command! AutoCloseCharsEnable g:autoclosechars_enabled = 1
  command! AutoCloseCharsDisable g:autoclosechars_enabled = 0
  command! AutoCloseCharsToggle autoclosechars.Toggle()
endif
