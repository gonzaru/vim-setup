vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_git') || !get(g:, 'git_enabled')
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
nnoremap <silent> <script> <Plug>(git-close) <ScriptCmd>git.Close()<CR>
nnoremap <silent> <script> <Plug>(git-help) <ScriptCmd>git.Help()<CR>
nnoremap <silent> <script> <Plug>(git-blame)
  \ <ScriptCmd>git.Blame(PrevOrNewFile(), getcwd(), false, true)<CR>
nnoremap <silent> <script> <Plug>(git-blame-short)
  \ <ScriptCmd>git.Blame(PrevOrNewFile(), getcwd(), true, true)<CR>
nnoremap <silent> <script> <Plug>(git-diff-file)
  \ <ScriptCmd>git.Run($"git diff {PrevOrNewFile()}", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-show)
  \ <ScriptCmd>git.Run($"git show", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-show-commit)
  \ <ScriptCmd>git.ShowCommit(getline('.'), getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-show-file)
  \ <ScriptCmd>git.Run($"git show {PrevOrNewFile()}", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-status)
  \ <ScriptCmd>git.Run($"git status", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-status-file)
  \ <ScriptCmd>git.Run($"git status {PrevOrNewFile()}", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-log) <ScriptCmd>git.Run('git log', getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-log-file)
  \ <ScriptCmd>git.Run($"git log {PrevOrNewFile()}", getcwd(), true)<CR>:setlocal syntax=gitrebase<CR>
nnoremap <silent> <script> <Plug>(git-log-one-file)
  \ <ScriptCmd>git.Run($"git log --oneline {PrevOrNewFile()}", getcwd(), true)<CR>:setlocal syntax=git<CR>

# previous or new file
def PrevOrNewFile(): string
  var cfile: string
  var file: string
  try
    cfile = expand('<cfile>')
  catch /^Vim\%((\a\+)\)\=:E446:/ # E446: No file name under cursor
  finally
    if filereadable(cfile)
      file = cfile
    elseif &filetype == git.GetGitFileType()
      if !empty(git.GetGitPrevFile())
        file = git.GetGitPrevFile()
      endif
    else
      file = expand('%:p')
    endif
  endtry
  if !filereadable(file)
    throw $"Error: file {file} is not readable"
  endif
  return file
enddef

# set mappings
if get(g:, 'git_no_mappings') == 0
  if empty(mapcheck("<leader>vc", "n"))
    nnoremap <leader>vc <Plug>(git-close)
  endif
  if empty(mapcheck("<leader>vs", "n"))
    nnoremap <leader>vs <Plug>(git-status)
  endif
  if empty(mapcheck("<leader>vS", "n"))
    nnoremap <leader>vS <Plug>(git-show)
  endif
endif

# set commands
if get(g:, 'git_no_commands') == 0
  command! -nargs=+ Git git.Run($'git <args>', getcwd(), true)
  command! GitBlame execute "normal \<Plug>(git-blame)"
  command! GitBlameShort execute "normal \<Plug>(git-blame-short)"
  command! GitBranch git.Run('git branch', getcwd(), false)
  command! GitBranchAll git.Run('git branch --all', getcwd(), false)
  command! GitBranchRemotes git.Run('git branch --remotes', getcwd(), false)
  command! GitClose execute "normal \<Plug>(git-close)"
  command! GitDiff git.Run('git diff', getcwd(), true)
  command! GitDiffFile execute "normal \<Plug>(git-diff-file)"
  command! GitDiffStaged git.Run('git diff --staged', getcwd(), true)
  command! GitDiffStagedFile git.Run($"git diff --staged {expand('%:p')}", getcwd(), true)
  command! GitHelp execute "normal \<Plug>(git-help)"
  command! GitLog execute "normal \<Plug>(git-log)"
  command! GitLogFile execute "normal \<Plug>(git-log-file)"
  command! GitLogOne git.Run('git log --oneline', getcwd(), true)
  command! GitLogOneFile execute "normal \<Plug>(git-log-one-file)"
  command! GitPull git.Run('git pull', getcwd(), false)
  # command! GitPush git.Run('git push', getcwd(), false)
  # command! GitPushForce git.Run('git push -f', getcwd(), false)
  command! GitShow execute "normal \<Plug>(git-show)"
  command! GitShowCommit execute "normal \<Plug>(git-show-commit)"
  command! GitShowFile execute "normal \<Plug>(git-show-file)"
  command! GitStashList git.Run('git stash list', getcwd(), true)
  command! GitStatus execute "normal \<Plug>(git-status)"
  command! GitStatusFile execute "normal \<Plug>(git-status-file)"
  command! GitStatusShort git.Run('git status --short', getcwd(), true)
  command! GitStatusShortFile git.Run($"git status --short {expand('%:p')}", getcwd(), true)
  command! GitTagList git.Run('git tag', getcwd(), false)
  command! GitTagRemoteList git.Run('git ls-remote --tags origin', getcwd(), false)
endif
