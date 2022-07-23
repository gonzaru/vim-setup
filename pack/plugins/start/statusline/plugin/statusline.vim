vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_statusline') || !get(g:, 'statusline_enabled') || &cp
  finish
endif
g:loaded_statusline = 1

# global variables
if !exists('g:statusline_showgitbranch')
  g:statusline_showgitbranch = 1
endif

# autoload
import autoload '../autoload/statusline.vim'

augroup statusline_mystatusline
  autocmd!
  autocmd BufNewFile,BufEnter,CmdlineLeave,ShellCmdPost,DirChanged,VimResume * statusline.MyStatusLine(expand('<afile>:p'))
augroup END

# TODO:
# set mappings
# define mappings
# if get(g:, 'statusline_no_mappings') == 0
# endif
