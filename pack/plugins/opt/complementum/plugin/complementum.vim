vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_complementum') || !get(g:, 'complementum_enabled') || &cp
  finish
endif
g:loaded_complementum = 1

# autoload
import autoload '../autoload/complementum.vim'

# define mappings
inoremap <silent> <unique> <script> <Plug>(complementum-goinsertautocomplete) <C-r>=<SID>complementum.GoInsertAutoComplete(getchar())<CR>

# TODO:
# define mappings
#
# set mappings
# if get(g:, 'complementum_no_mappings') == 0
# endif
#
# set commands
# if get(g:, 'complementum_no_commands') == 0
# endif
