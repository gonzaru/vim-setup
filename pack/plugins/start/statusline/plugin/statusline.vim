vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_statusline') || !get(g:, 'statusline_enabled')
  finish
endif
g:loaded_statusline = true

# global variables
if !exists('g:statusline_showgitbranch')
  g:statusline_showgitbranch = true
endif

# autoload
import autoload '../autoload/statusline.vim'

augroup statusline_mystatusline
  autocmd!
  autocmd BufNewFile,BufEnter,CmdwinLeave,ShellCmdPost,DirChanged,VimResume * {
    if g:statusline_enabled
      statusline.MyStatusLineAsync(expand('<afile>:p'))
    endif
  }
augroup END

# define mappings
nnoremap <silent> <script> <Plug>(statusline-git-enable) :StatusLineGitEnable<CR>
nnoremap <silent> <script> <Plug>(statusline-git-disable) :StatusLineGitDisable<CR>
nnoremap <silent> <script> <Plug>(statusline-git-toggle) :StatusLineGitToggle<CR>

# set mappings
if get(g:, 'statusline_no_mappings') == 0
  if empty(mapcheck("<leader>tgg", "n"))
    nnoremap <leader>tgg <Plug>(statusline-git-toggle)
  endif
endif

# set commands
if get(g:, 'statusline_no_commands') == 0
  command! StatusLineGitEnable {
    g:statusline_showgitbranch = true
    statusline.MyStatusLineAsync(expand('%:p'))
  }
  command! StatusLineGitDisable {
    statusline.SetStatus("")
    g:statusline_showgitbranch = false
  }
  command! StatusLineGitToggle {
    if g:statusline_showgitbranch
      execute "normal \<Plug>(statusline-git-disable)"
    else
      execute "normal \<Plug>(statusline-git-enable)"
    endif
    v:statusmsg = $"statusline_showgitbranch={g:statusline_showgitbranch}"
  }
endif
