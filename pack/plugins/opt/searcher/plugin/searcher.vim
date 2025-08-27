vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_searcher') || !get(g:, 'searcher_enabled')
  finish
endif
g:loaded_searcher = true

# global variables
if !exists('g:searcher_findprg_command')
  g:searcher_findprg_command = [
    'fd', '--type', 'f', '--follow', '--color=never', '--unrestricted', '--exclude', '.git'
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
if !exists('g:searcher_grepprg_command')
  # --vimgrep
  g:searcher_grepprg_command = [
    'rg', '--with-filename', '--line-number', '--column', '--no-heading', '--color=never', '-uu', '--glob', '!.git/'
  ]
endif
if !exists('g:searcher_grepprg_sensitive')
  g:searcher_grepprg_sensitive = ['--case-sensitive']
endif
if !exists('g:searcher_grepprg_insensitive')
  g:searcher_grepprg_insensitive = ['--ignore-case']
endif
if !exists('g:searcher_gitprg_command')
  g:searcher_gitprg_command = [
    'git', 'grep', '--line-number', '--column', '--color=never'
  ]
endif
if !exists('g:searcher_gitprg_sensitive')
  g:searcher_gitprg_sensitive = []
endif
if !exists('g:searcher_gitprg_insensitive')
  g:searcher_gitprg_insensitive = ['--ignore-case']
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
  if empty(mapcheck("<leader>sp", "n"))
    nnoremap <leader>sp <Plug>(searcher-git)
  endif
  if empty(mapcheck("<leader>sP", "n"))
    nnoremap <leader>sP <Plug>(searcher-git-root)
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
endif
