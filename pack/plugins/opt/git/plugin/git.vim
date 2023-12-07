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
nnoremap <silent> <script> <Plug>(git-add-file) <ScriptCmd>git.Run($"git add {PrevOrNewFile()}", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-blame) <ScriptCmd>git.Blame(PrevOrNewFile(), getcwd(), false, true)<CR>
nnoremap <silent> <script> <Plug>(git-blame-short) <ScriptCmd>git.Blame(PrevOrNewFile(), getcwd(), true, true)<CR>
nnoremap <silent> <script> <Plug>(git-branch) <ScriptCmd>git.Run("git branch", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-branch-all) <ScriptCmd>git.Run("git branch --all", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-branch-remotes) <ScriptCmd>git.Run("git branch --remotes", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-checkout-file)
  \ <ScriptCmd>git.CheckOutFile(PrevOrNewFile(), getcwd(), false, false)<CR>
nnoremap <silent> <script> <Plug>(git-close) <ScriptCmd>git.Close()<CR>
nnoremap <silent> <script> <Plug>(git-diff) <ScriptCmd>git.Run("git diff", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-diff-file) <ScriptCmd>git.Run($"git diff {PrevOrNewFile()}", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-do-action) <ScriptCmd>git.DoAction(getline('.'), getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-help) <ScriptCmd>git.Help()<CR>
nnoremap <silent> <script> <Plug>(git-log) <ScriptCmd>git.Run("git log", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-log-file) <ScriptCmd>git.Run($"git log {PrevOrNewFile()}", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-log-oneline) <ScriptCmd>git.Run("git log --oneline", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-log-one-file)
  \ <ScriptCmd>git.Run($"git log --oneline {PrevOrNewFile()}", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-pull) <ScriptCmd>git.Run("git pull", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-restore-staged-file)
  \ <ScriptCmd>git.Run($"git restore --staged {PrevOrNewFile()}", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-show) <ScriptCmd>git.Run("git show", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-show-file) <ScriptCmd>git.Run($"git show {PrevOrNewFile()}", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-stash-list) <ScriptCmd>git.Run("git stash list", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-status) <ScriptCmd>git.Run("git status", getcwd(), true)<CR>
nnoremap <silent> <script> <Plug>(git-status-file)
  \ <ScriptCmd>git.Run($"git status {PrevOrNewFile()}", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-tag-list) <ScriptCmd>git.Run("git tag", getcwd(), false)<CR>
nnoremap <silent> <script> <Plug>(git-tag-list-remote)
  \ <ScriptCmd>git.Run("git ls-remote --tags origin", getcwd(), false)<CR>

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
    elseif &filetype == git.GitFileType()
      if !empty(git.GitPrevFile())
        file = git.GitPrevFile()
      endif
    else
      file = expand('%:p')
    endif
  endtry
  if !filereadable(file)
    throw $"Error: the file '{file}' is not readable"
  endif
  return file
enddef

# set mappings
if get(g:, 'git_no_mappings') == 0
  if empty(mapcheck("<leader>vb", "n"))
    nnoremap <leader>vb <Plug>(git-branch)
  endif
  if empty(mapcheck("<leader>vB", "n"))
    nnoremap <leader>vB <Plug>(git-branch-all)
  endif
  if empty(mapcheck("<leader>VB", "n"))
    nnoremap <leader>VB <Plug>(git-branch-remotes)
  endif
  if empty(mapcheck("<leader>vc", "n"))
    nnoremap <leader>vc <Plug>(git-close)
  endif
  if empty(mapcheck("<leader>vd", "n"))
    nnoremap <leader>vd <Plug>(git-diff)
  endif
  if empty(mapcheck("<leader>vh", "n"))
    nnoremap <leader>vh <Plug>(git-stash-list)
  endif
  if empty(mapcheck("<leader>vl", "n"))
    nnoremap <leader>vl <Plug>(git-log)
  endif
  if empty(mapcheck("<leader>vL", "n"))
    nnoremap <leader>vL <Plug>(git-log-oneline)
  endif
  if empty(mapcheck("<leader>vp", "n"))
    nnoremap <leader>vp <Plug>(git-pull)
  endif
  if empty(mapcheck("<leader>vs", "n"))
    nnoremap <leader>vs <Plug>(git-status)
  endif
  if empty(mapcheck("<leader>vS", "n"))
    nnoremap <leader>vS <Plug>(git-show)
  endif
  if empty(mapcheck("<leader>vt", "n"))
    nnoremap <leader>vt <Plug>(git-tag-list)
  endif
  if empty(mapcheck("<leader>vT", "n"))
    nnoremap <leader>vT <Plug>(git-tag-list-remote)
  endif
endif

# set commands
if get(g:, 'git_no_commands') == 0
  command! -nargs=+ Git git.Run($'git <args>', getcwd(), false)
  command! GitAddFile execute "normal \<Plug>(git-add-file)"
  command! GitBlame execute "normal \<Plug>(git-blame)"
  command! GitBlameShort execute "normal \<Plug>(git-blame-short)"
  command! GitBranch execute "normal \<Plug>(git-branch)"
  command! GitBranchAll execute "normal \<Plug>(git-branch-all)"
  command! GitBranchRemotes execute "normal \<Plug>(git-branch-remotes)"
  command! GitCheckOutFile execute "normal \<Plug>(git-checkout-file)"
  command! GitClose execute "normal \<Plug>(git-close)"
  command! GitDiff execute "normal \<Plug>(git-diff)"
  command! GitDiffFile execute "normal \<Plug>(git-diff-file)"
  command! GitDiffStaged git.Run('git diff --staged', getcwd(), true)
  command! GitDiffStagedFile git.Run($"git diff --staged {expand('%:p')}", getcwd(), false)
  command! GitDoAction execute "normal \<Plug>(git-do-action)"
  command! GitHelp execute "normal \<Plug>(git-help)"
  command! GitLog execute "normal \<Plug>(git-log)"
  command! GitLogFile execute "normal \<Plug>(git-log-file)"
  command! GitLogOne execute "normal \<Plug>(git-log-onefile)"
  command! GitLogOneFile execute "normal \<Plug>(git-log-one-file)"
  command! GitPull execute "normal \<Plug>(git-pull)"
  # command! GitPush git.Run('git push', getcwd(), false)
  # command! GitPushForce git.Run('git push -f', getcwd(), false)
  command! GitRestoreStagedFile execute "normal \<Plug>(git-restore-staged-file)"
  command! GitShow execute "normal \<Plug>(git-show)"
  command! GitShowFile execute "normal \<Plug>(git-show-file)"
  command! GitStashList execute "normal \<Plug>(git-stash-list)"
  command! GitStatus execute "normal \<Plug>(git-status)"
  command! GitStatusFile execute "normal \<Plug>(git-status-file)"
  command! GitStatusShort git.Run('git status --short', getcwd(), true)
  command! GitStatusShortFile git.Run($"git status --short {expand('%:p')}", getcwd(), false)
  command! GitTagList execute "normal \<Plug>(git-tag-list)"
  command! GitTagListRemote execute "normal \<Plug>(git-tag-list-remote)"
endif
