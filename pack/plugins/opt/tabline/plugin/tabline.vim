vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_tabline') || !get(g:, 'tabline_enabled') || &cp
  finish
endif
g:loaded_tabline = 1

# autoload
import autoload '../autoload/tabline.vim'

# TODO:
# define mappings
#
# set mappings
# if get(g:, 'tabline_no_mappings') == 0
# endif
#
# set commands
# if get(g:, 'tabline_no_commands') == 0
# endif
