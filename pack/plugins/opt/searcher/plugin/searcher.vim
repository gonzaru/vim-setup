vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_searcher') || !get(g:, 'searcher_enabled')
  finish
endif
g:loaded_searcher = true

# global variables
if !exists('g:searcher_findprg_cmd')
  g:searcher_findprg_cmd = [
    'fd', '--type', 'f', '--follow', '--color=never', '--unrestricted',
    '--exclude', '.git',
    '--exclude', '.cache',
    '--exclude', '.idea',
    '--exclude', '.venv',
    '--exclude', 'node_modules',
  ]
endif
if !exists('g:searcher_findprg_sensitive')
  g:searcher_findprg_sensitive = ['--case-sensitive']
endif
if !exists('g:searcher_findprg_insensitive')
  g:searcher_findprg_insensitive = ['--ignore-case']
endif
if !exists('g:searcher_findprg_directory')
  g:searcher_findprg_directory = ['--absolute-path', '--base-directory']
endif
if !exists('g:searcher_grepprg_cmd')
  # --vimgrep
  g:searcher_grepprg_cmd = [
    'rg', '--with-filename', '--line-number', '--column', '--no-heading', '--color=never', '-uu', '--glob', '!.git/'
  ]
endif
if !exists('g:searcher_grepprg_sensitive')
  g:searcher_grepprg_sensitive = ['--case-sensitive']
endif
if !exists('g:searcher_grepprg_insensitive')
  g:searcher_grepprg_insensitive = ['--ignore-case']
endif
if !exists('g:searcher_gitprg_cmd')
  g:searcher_gitprg_cmd = [
    'git', 'grep', '--line-number', '--column', '--color=never'
  ]
endif
if !exists('g:searcher_gitprg_sensitive')
  g:searcher_gitprg_sensitive = []
endif
if !exists('g:searcher_gitprg_insensitive')
  g:searcher_gitprg_insensitive = ['--ignore-case']
endif
# popup
if !exists('g:searcher_popup_mode')
  g:searcher_popup_mode = 'edit'
endif
if !exists('g:searcher_popup_kind')
  g:searcher_popup_kind = 'find'
endif
if !exists('g:searcher_popup_grep_minchars')
  g:searcher_popup_grep_minchars = 3  # >= 1
endif
if !exists('g:searcher_popup_find_async')
  g:searcher_popup_find_async = true
endif
if !exists('g:searcher_popup_fuzzy')
  g:searcher_popup_fuzzy = false
endif
if !exists('g:searcher_popup_fuzzy_limit')
  g:searcher_popup_fuzzy_limit = 200
endif
if !exists('g:searcher_popup_find_limit')
  g:searcher_popup_find_limit = 25
endif
if !exists('g:searcher_popup_history_ex_limit')
  g:searcher_popup_history_ex_limit = 200
endif
if !exists('g:searcher_popup_history_search_limit')
  g:searcher_popup_history_search_limit = 200
endif

# autoload
import autoload '../autoload/searcher.vim'

# define mappings
nnoremap <silent> <script> <plug>(searcher-find)
  \ <ScriptCmd>feedkeys(":SearcherFind '-i', '', '-p', '" .. fnamemodify(getcwd(), ":~") .. "'<S-Left><S-Left><S-Left><Right>")<CR>
nnoremap <silent> <script> <plug>(searcher-find-root)
  \ <ScriptCmd>feedkeys(":SearcherFind '-i', '', '-p', '" .. systemlist('git rev-parse --show-toplevel')[0] .. "'<S-Left><S-Left><S-Left><Right>")<CR>
nnoremap <silent> <script> <plug>(searcher-lfind)
  \ <ScriptCmd>feedkeys(":SearcherLFind '-i', '', '-p', '" .. fnamemodify(getcwd(), ":~") .. "'<S-Left><S-Left><S-Left><Right>")<CR>
nnoremap <silent> <script> <plug>(searcher-find-word)
  \ <ScriptCmd>searcher.Search(expand('<cword>'), '-p', getcwd(), 'findprg', 'quickfix')<CR>
nnoremap <silent> <script> <plug>(searcher-lfind-word)
  \ <ScriptCmd>searcher.Search(expand('<cword>'), '-p', getcwd(), 'findprg', 'locationlist')<CR>
nnoremap <silent> <script> <plug>(searcher-grep)
  \ <ScriptCmd>feedkeys(":SearcherGrep '-i', '', '" .. fnamemodify(getcwd(), ":~") .. "'<S-Left><S-Left><Right>")<CR>
nnoremap <silent> <script> <plug>(searcher-grep-root)
  \ <ScriptCmd>feedkeys(":SearcherGrep '-i', '', '"  .. systemlist('git rev-parse --show-toplevel')[0] .. "'<S-Left><S-Left><Right>")<CR>
nnoremap <silent> <script> <plug>(searcher-lgrep)
  \ <ScriptCmd>feedkeys(":SearcherLGrep '-i', '', '" .. fnamemodify(getcwd(), ":~") .. "'<S-Left><S-Left><Right>")<CR>
nnoremap <silent> <script> <plug>(searcher-grep-word)
  \ <ScriptCmd>searcher.Search(expand('<cword>'), getcwd(), 'grepprg', 'quickfix')<CR>
nnoremap <silent> <script> <plug>(searcher-grep-word-root)
  \ <ScriptCmd>searcher.Search(expand('<cword>'), systemlist('git rev-parse --show-toplevel')[0], 'grepprg', 'quickfix')<CR>
nnoremap <silent> <script> <plug>(searcher-lgrep-word)
  \ <ScriptCmd>searcher.Search(expand('<cword>'), getcwd(), 'grepprg', 'locationlist')<CR>
nnoremap <silent> <script> <plug>(searcher-git)
  \ <ScriptCmd>feedkeys(":SearcherGit '-i', '', '" .. fnamemodify(getcwd(), ":~") .. "'<S-Left><S-Left><Right>")<CR>
nnoremap <silent> <script> <plug>(searcher-git-root)
  \ <ScriptCmd>feedkeys(":SearcherGit '-i', '', '" .. systemlist('git rev-parse --show-toplevel')[0] .. "'<S-Left><S-Left><Right>")<CR>
nnoremap <silent> <script> <plug>(searcher-git-word)
  \ <ScriptCmd>searcher.Search(expand('<cword>'), getcwd(), 'gitprg', 'quickfix')<CR>
nnoremap <silent> <script> <plug>(searcher-lgit-word)
  \ <ScriptCmd>searcher.Search(expand('<cword>'), getcwd(), 'gitprg', 'locationlist')<CR>
nnoremap <silent> <script> <plug>(searcher-popup-find) <ScriptCmd>searcher.Popup("find")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-grep) <ScriptCmd>searcher.Popup("grep")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-recent) <ScriptCmd>searcher.Popup("recent")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-buffers) <ScriptCmd>searcher.Popup("buffers")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-sessions) <ScriptCmd>searcher.Popup("sessions")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-changes) <ScriptCmd>searcher.Popup("changes")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-jumps) <ScriptCmd>searcher.Popup("jumps")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-quickfix) <ScriptCmd>searcher.Popup("quickfix")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-marks) <ScriptCmd>searcher.Popup("marks")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-mappings) <ScriptCmd>searcher.Popup("mappings")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-commands) <ScriptCmd>searcher.Popup("commands")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-completions) <ScriptCmd>searcher.Popup("completions")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-themes) <ScriptCmd>searcher.Popup("themes")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-history-ex) <ScriptCmd>searcher.Popup("history-ex")<CR>
nnoremap <silent> <script> <plug>(searcher-popup-history-search) <ScriptCmd>searcher.Popup("history-search")<CR>

# set mappings
if get(g:, 'searcher_no_mappings') == 0
  if empty(mapcheck("<leader>sf", "n"))
    nnoremap <leader>sf <Plug>(searcher-find)
  endif
  if empty(mapcheck("<leader>sF", "n"))
    nnoremap <leader>sF <Plug>(searcher-find-root)
  endif
  #if empty(mapcheck("<leader>Sf", "n"))
  #  nnoremap <leader>Sf <Plug>(searcher-lfind)
  #endif
  #if empty(mapcheck("<leader>SF", "n"))
  #  nnoremap <leader>SF <Plug>(searcher-lfind-word)
  #endif
  if empty(mapcheck("<leader>sg", "n"))
    nnoremap <leader>sg <Plug>(searcher-grep)
  endif
  if empty(mapcheck("<leader>sG", "n"))
    nnoremap <leader>sG <Plug>(searcher-grep-root)
  endif
  if empty(mapcheck("<leader>sw", "n"))
    nnoremap <leader>sw <Plug>(searcher-grep-word)
  endif
  if empty(mapcheck("<leader>sW", "n"))
    nnoremap <leader>sW <Plug>(searcher-grep-word-root)
  endif
  #if empty(mapcheck("<leader>Sg", "n"))
  #  nnoremap <leader>Sg <Plug>(searcher-lgrep)
  #endif
  #if empty(mapcheck("<leader>sG", "n"))
  #  nnoremap <leader>sG <Plug>(searcher-grep-word)
  #endif
  #if empty(mapcheck("<leader>SG", "n"))
  #  nnoremap <leader>SG <Plug>(searcher-lgrep-word)
  #endif
  if empty(mapcheck("<leader>sk", "n"))
    nnoremap <leader>sk <Plug>(searcher-git)
  endif
  if empty(mapcheck("<leader>sK", "n"))
    nnoremap <leader>sK <Plug>(searcher-git-root)
  endif
  #if empty(mapcheck("<leader>Sp", "n"))
  #  nnoremap <leader>Sp <Plug>(searcher-lgit)
  #endif
  #if empty(mapcheck("<leader>sP", "n"))
  #  nnoremap <leader>sP <Plug>(searcher-git-word)
  #endif
  #if empty(mapcheck("<leader>SP", "n"))
  #  nnoremap <leader>SP <Plug>(searcher-lgit-word)
  #endif
  if empty(mapcheck("<leader>ff", "n"))
    nnoremap <leader>ff <Plug>(searcher-popup-find)
  endif
  if empty(mapcheck("<leader>fg", "n"))
    nnoremap <leader>fg <Plug>(searcher-popup-grep)
  endif
  if empty(mapcheck("<leader>fo", "n"))
    nnoremap <leader>fo <Plug>(searcher-popup-recent)
  endif
  if empty(mapcheck("<leader>fb", "n"))
    nnoremap <leader>fb <Plug>(searcher-popup-buffers)
  endif
  if empty(mapcheck("<leader>fs", "n"))
    nnoremap <leader>fs <Plug>(searcher-popup-sessions)
  endif
  if empty(mapcheck("<leader>fc", "n"))
    nnoremap <leader>fc <Plug>(searcher-popup-changes)
  endif
  if empty(mapcheck("<leader>fj", "n"))
    nnoremap <leader>fj <Plug>(searcher-popup-jumps)
  endif
  if empty(mapcheck("<leader>fq", "n"))
    nnoremap <leader>fq <Plug>(searcher-popup-quickfix)
  endif
  if empty(mapcheck("<leader>fk", "n"))
    nnoremap <leader>fk <Plug>(searcher-popup-commands)
  endif
  if empty(mapcheck("<leader>ft", "n"))
    nnoremap <leader>ft <Plug>(searcher-popup-themes)
  endif
  if empty(mapcheck("<leader>f*", "n"))
    nnoremap <leader>f* <Plug>(searcher-popup-completions)
  endif
  if empty(mapcheck("<leader>f'", "n"))
    nnoremap <leader>f' <Plug>(searcher-popup-marks)
  endif
  if empty(mapcheck("<leader>f_", "n"))
    nnoremap <leader>f_ <Plug>(searcher-popup-mappings)
  endif
  if empty(mapcheck("<leader>f:", "n"))
    nnoremap <leader>f: <Plug>(searcher-popup-history-ex)
  endif
  if empty(mapcheck("<leader>f/", "n"))
    nnoremap <leader>f/ <Plug>(searcher-popup-history-search)
  endif
endif

# set commands
if get(g:, 'searcher_no_commands') == 0
  command! -nargs=+ -complete=file -bar SearcherFind searcher.Search(<args>, 'findprg', 'quickfix')
  command! -nargs=+ -complete=file -bar SearcherLFind searcher.Search(<args>, 'findprg', 'locationlist')
  command! -nargs=0 -bar SearcherFindWord execute "normal \<Plug>(searcher-find-word)"
  command! -nargs=0 -bar SearcherLFindWord execute "normal \<Plug>(searcher-lfind-word)"
  command! -nargs=+ -complete=file -bar SearcherGrep searcher.Search(<args>, 'grepprg', 'quickfix')
  command! -nargs=+ -complete=file -bar SearcherLGrep searcher.Search(<args>, 'grepprg', 'locationlist')
  command! -nargs=0 -bar SearcherGrepWord execute "normal \<Plug>(searcher-grep-word)"
  command! -nargs=0 -bar SearcherLGrepWord execute "normal \<Plug>(searcher-lgrep-word)"
  command! -nargs=+ -complete=file -bar SearcherGit searcher.Search(<args>, 'gitprg', 'quickfix')
  command! -nargs=+ -complete=file -bar SearcherLGit searcher.Search(<args>, 'gitprg', 'locationlist')
  command! -nargs=0 -bar SearcherGitWord execute "normal \<Plug>(searcher-git-word)"
  command! -nargs=0 -bar SearcherLGitWord execute "normal \<Plug>(searcher-lgit-word)"
  command! -nargs=0 SearcherPopupFind execute "normal \<Plug>(searcher-popup-find)"
  command! -nargs=0 SearcherPopupGrep execute "normal \<Plug>(searcher-popup-grep)"
  command! -nargs=0 SearcherPopupRecent execute "normal \<Plug>(searcher-popup-recent)"
  command! -nargs=0 SearcherPopupBuffers execute "normal \<Plug>(searcher-popup-buffers)"
  command! -nargs=0 SearcherPopupSessions execute "normal \<Plug>(searcher-popup-sessions)"
  command! -nargs=0 SearcherPopupChanges execute "normal \<Plug>(searcher-popup-changes)"
  command! -nargs=0 SearcherPopupJumps execute "normal \<Plug>(searcher-popup-jumps)"
  command! -nargs=0 SearcherPopupQuickfix execute "normal \<Plug>(searcher-popup-quickfix)"
  command! -nargs=0 SearcherPopupMarks execute "normal \<Plug>(searcher-popup-marks)"
  command! -nargs=0 SearcherPopupMappings execute "normal \<Plug>(searcher-popup-mappings)"
  command! -nargs=0 SearcherPopupCommands execute "normal \<Plug>(searcher-popup-commands)"
  command! -nargs=0 SearcherPopupCompletions execute "normal \<Plug>(searcher-popup-completions)"
  command! -nargs=0 SearcherPopupThemes execute "normal \<Plug>(searcher-popup-themes)"
  command! -nargs=0 SearcherPopupHistoryEx execute "normal \<Plug>(searcher-popup-history-ex)"
  command! -nargs=0 SearcherPopupHistorySearch execute "normal \<Plug>(searcher-popup-history-search)"
endif
