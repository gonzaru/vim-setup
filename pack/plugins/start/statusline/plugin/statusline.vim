vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_statusline') || !get(g:, 'statusline_enabled')
  finish
endif
g:loaded_statusline = true

# global variables
g:statusline_isgitbranch = false
if !exists('g:statusline_gitbranch')
  g:statusline_gitbranch = true
endif
if !exists('g:statusline_gitstatusfile')
  g:statusline_gitstatusfile = false
endif

# autoload
import autoload '../autoload/statusline.vim'

# autocmd
augroup statusline_gitstatusline
  autocmd!
  autocmd BufNewFile,BufEnter,BufWritePost,CmdwinLeave,ShellCmdPost,VimResume * {
    if g:statusline_gitbranch
      var fpath = expand('%:p')
      if g:statusline_enabled && &buftype == '' && !empty(fpath)
        statusline.GitBranch(fpath)
      else
        statusline.SetStatus('')
      endif
    endif
  }
  # autocmd BufEnter,DirChanged * {
  #   if g:statusline_enabled && &buftype == '' && empty(bufname())
  #     statusline.GitBranch(getcwd())
  #   else
  #     statusline.SetStatus('')
  #   endif
  # }

# define mappings
nnoremap <silent> <script> <Plug>(statusline-git-enable) :StatusLineGitEnable<CR>
nnoremap <silent> <script> <Plug>(statusline-git-disable) :StatusLineGitDisable<CR>
nnoremap <silent> <script> <Plug>(statusline-git-toggle) :StatusLineGitToggle<CR>

# set mappings
if get(g:, 'statusline_no_mappings') == 0
  if empty(mapcheck('<leader>tgg', 'n'))
    nnoremap <leader>tgg <Plug>(statusline-git-toggle)
  endif
endif

# set commands
if get(g:, 'statusline_no_commands') == 0
  command! StatusLineGitEnable {
    g:statusline_gitbranch = true
    statusline.GitBranch(expand('%:p'))
    statusline.GitFileStatus(expand('%:p'))
  }
  command! StatusLineGitDisable {
    statusline.SetStatus('')
    g:statusline_gitbranch = false
  }
  command! StatusLineGitToggle {
    if g:statusline_gitbranch
      execute "normal \<Plug>(statusline-git-disable)"
    else
      execute "normal \<Plug>(statusline-git-enable)"
    endif
    v:statusmsg = $'statusline_gitbranch={g:statusline_gitbranch}'
  }
  command! StatusLineGitStatusFileToggle {
    if g:statusline_gitstatusfile
      g:statusline_gitstatusfile = false
      statusline.ClearGitStatusFile()
    else
      g:statusline_gitstatusfile = true
      var fpath = expand('%:p')
      if g:statusline_enabled && &buftype == '' && !empty(fpath)
        statusline.GitBranch(fpath)
      endif
    endif
    v:statusmsg = $'statusline_gitstatusfile={g:statusline_gitstatusfile}'
  }
endif
