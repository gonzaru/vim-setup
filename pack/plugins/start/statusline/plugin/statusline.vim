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
  autocmd BufNewFile,BufEnter,CmdwinLeave,ShellCmdPost,DirChanged,VimResume * statusline.MyStatusLineAsync(expand('<afile>:p'))
augroup END

# define mappings
nnoremap <silent> <unique> <script> <Plug>(statusline-git-enable) :StatusLineGitEnable<CR>
nnoremap <silent> <unique> <script> <Plug>(statusline-git-disable) :StatusLineGitDisable<CR>
nnoremap <silent> <unique> <script> <Plug>(statusline-git-toggle) :StatusLineGitToggle<CR>

# TODO:
# set mappings
# if get(g:, 'statusline_no_mappings') == 0
# endif

# set commands
if get(g:, 'statusline_no_commands') == 0
  command! StatusLineGitEnable {
    g:statusline_showgitbranch = 1
    statusline.MyStatusLineAsync(expand('%:p'))
  }
  command! StatusLineGitDisable {
    statusline.SetStatus("")
    g:statusline_showgitbranch = 0
  }
  command! StatusLineGitToggle {
    if g:statusline_showgitbranch == 1
      execute "normal! \<Plug>(statusline-git-disable)"
    else
      execute "normal! \<Plug>(statusline-git-enable)"
    endif
    v:statusmsg = "statusline_showgitbranch=" .. g:statusline_showgitbranch
  }
endif
