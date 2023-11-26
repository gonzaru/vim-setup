vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_git') || !get(g:, 'git_enabled')
  finish
endif
g:loaded_git = true

# global variables
if !exists('g:git_position')
  g:git_position = 'top'
endif

# autoload
import autoload '../autoload/git.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(git-close) <ScriptCmd>git.Close()<CR>

# set mappings
if get(g:, 'git_no_mappings') == 0
  if empty(mapcheck("<leader>GC", "n"))
    nnoremap <leader>GC <Plug>(git-close)
  endif
endif

# set commands
if get(g:, 'git_no_commands') == 0
  command! -nargs=+ Git git.Run('git ' .. '<args>', getcwd())
  command! GitBlame git.Blame(expand('%:p'), getcwd())
  command! GitBranch git.Run('git branch', getcwd())
  command! GitBranchAll git.Run('git branch --all', getcwd())
  command! GitBranchRemotes git.Run('git branch --remotes', getcwd())
  command! GitClose execute "normal \<Plug>(git-close)"
  command! GitDiff git.Run('git diff', getcwd())
  command! GitDiffStaged git.Run('git diff --staged', getcwd())
  command! GitLog git.Run('git log', getcwd())
  command! GitLogOne git.Run('git log --oneline', getcwd())
  command! GitShow git.Run('git show', getcwd())
  command! GitStashList git.Run('git stash list', getcwd())
  command! GitStatus git.Run('git status', getcwd())
  command! GitStatusShort git.Run('git status --short', getcwd())
  command! GitTag git.Run('git tag', getcwd())
  command! GitTagRemote git.Run('git ls-remote --tags origin', getcwd())
endif
