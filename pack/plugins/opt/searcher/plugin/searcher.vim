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
    'fd', '--type', 'f', '--follow', '--strip-cwd-prefix', '--color=never', '--unrestricted', '--exclude', '.git'
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
  g:searcher_grepprg_command = [
    'rg', '--vimgrep', '--line-number', '--no-heading', '--color=never', '-uu', '--glob', '!.git/'
  ]
endif
if !exists('g:searcher_grepprg_sensitive')
  g:searcher_grepprg_sensitive = ['--case-sensitive']
endif
if !exists('g:searcher_grepprg_insensitive')
  g:searcher_grepprg_insensitive = ['--ignore-case']
endif

# autoload
import autoload '../autoload/searcher.vim'

# define mappings
nnoremap <silent> <script> <plug>(searcher-find)
  \ <ScriptCmd>feedkeys(':SearcherFind -i ' .. fnamemodify(getcwd(), ":~") .. ' ')<CR>
nnoremap <silent> <script> <plug>(searcher-find-word)
  \ <ScriptCmd>searcher.Find(expand('<cword>'), 'quickfix')<CR>
nnoremap <silent> <script> <plug>(searcher-lfind-word)
  \ <ScriptCmd>searcher.Find(expand('<cword>'), 'locationlist')<CR>
nnoremap <silent> <script> <plug>(searcher-grep)
  \ <ScriptCmd>feedkeys(':SearcherGrep -i ' .. fnamemodify(getcwd(), ":~") .. '<C-f>Bba<Space><C-c>')<CR>
nnoremap <silent> <script> <plug>(searcher-grep-word)
  \ <ScriptCmd>searcher.Grep(expand('<cword>'), 'quickfix')<CR>
nnoremap <silent> <script> <plug>(searcher-lgrep-word)
  \ <ScriptCmd>searcher.Grep(expand('<cword>'), 'locationlist')<CR>

# set mappings
if get(g:, 'searcher_no_mappings') == 0
  if empty(mapcheck("<leader>sf", "n"))
    nnoremap <leader>sf <Plug>(searcher-find)
  endif
  if empty(mapcheck("<leader>sF", "n"))
    nnoremap <leader>sF <Plug>(searcher-find-word)
  endif
  if empty(mapcheck("<leader>SF", "n"))
    nnoremap <leader>SF <Plug>(searcher-lfind-word)
  endif
  if empty(mapcheck("<leader>sg", "n"))
    nnoremap <leader>sg <Plug>(searcher-grep)
  endif
  if empty(mapcheck("<leader>sG", "n"))
    nnoremap <leader>sG <Plug>(searcher-grep-word)
  endif
  if empty(mapcheck("<leader>SG", "n"))
    nnoremap <leader>SG <Plug>(searcher-lgrep-word)
  endif
endif

# set commands
if get(g:, 'searcher_no_commands') == 0
  command! -nargs=+ -complete=file -bar SearcherFind searcher.Find('<args>', 'quickfix')
  command! -nargs=+ -complete=file -bar SearcherLFind searcher.Find('<args>', 'locationlist')
  command! -nargs=0 -bar SearcherFindWord searcher.Find(expand('<cword>'), 'quickfix')
  command! -nargs=0 -bar SearcherLFindWord searcher.Find(expand('<cword>'), 'locationlist')
  command! -nargs=+ -complete=file -bar SearcherGrep searcher.Grep('<args>', 'quickfix')
  command! -nargs=+ -complete=file -bar SearcherLGrep searcher.Grep('<args>', 'locationlist')
  command! -nargs=0 -bar SearcherGrepWord searcher.Grep(expand('<cword>'), 'quickfix')
  command! -nargs=0 -bar SearcherLGrepWord searcher.Grep(expand('<cword>'), 'locationlist')
endif
