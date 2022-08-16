vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_format') || !get(g:, 'format_enabled') || &cp
  finish
endif
g:loaded_format = 1

# autoload
import autoload '../autoload/format.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(format-language) <ScriptCmd>format.Language()<CR>

# set mappings
if get(g:, 'format_no_mappings') == 0
  if empty(mapcheck("<leader>fm", "n"))
    nnoremap <leader>fm <Plug>(format-language)
  endif
endif

# set commands
if get(g:, 'format_no_commands') == 0
  command! FormatLanguage format.Language()
endif
