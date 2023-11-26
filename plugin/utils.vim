vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_utils') || !get(g:, 'utils_enabled')
  finish
endif
g:loaded_utils = true

# autoload
import autoload '../autoload/utils.vim'

# TODO:
# define mappings
#
# set mappings
# if get(g:, 'utils_no_mappings') == 0
# endif
#
# set commands
# if get(g:, 'utils_no_commands') == 0
# endif
