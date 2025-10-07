vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_complementum') || !get(g:, 'complementum_enabled')
  finish
endif
g:loaded_complementum = true

# global variables
if !exists('g:complementum_debuginfo')
  g:complementum_debuginfo = false
endif
if !exists('g:complementum_minchars')
  g:complementum_minchars = 1  # >= 1
endif
if !exists('g:complementum_omnichars')
  g:complementum_omnichars = {
    'python': ["."],
    'go': ["."],
    'c': [".", "#"],
    'terraform': ["."],
  }
endif
if !exists('g:complementum_omnifuncs')
  g:complementum_omnifuncs = {
    'python': ["python3complete#Complete"],
    'go': ["go#complete#Complete"],
    'c': ["ccomplete#Complete"],
  }
endif
if !exists('g:complementum_lspfuncs')
  g:complementum_lspfuncs = {
    'python': ['lsp#OmniFunc', 'g:LspOmniFunc'],
    'go': ['lsp#OmniFunc', 'g:LspOmniFunc'],
    'c': ['g:LspOmniFunc'],
    'terraform': ['lsp#OmniFunc', 'g:LspOmniFunc'],
  }
endif
if !exists('g:complementum_regex_dict')
  g:complementum_regex_dict = 'go-stdlib.dict\|go-project.dict'
endif
if !exists('g:complementum_keystroke_default')
  g:complementum_keystroke_default = "\<C-n>"
endif
if !exists('g:complementum_keystroke_default_orig')
  g:complementum_keystroke_default_orig = g:complementum_keystroke_default
endif
if !exists('g:complementum_keystroke_default_toggle')
  g:complementum_keystroke_default_toggle = "\<C-x>\<C-n>"
endif
if !exists('g:complementum_keystroke_dict')
  g:complementum_keystroke_dict = "\<C-x>\<C-k>"
endif
if !exists('g:complementum_keystroke_func')
  g:complementum_keystroke_func = "\<C-x>\<C-u>"
endif
if !exists('g:complementum_keystroke_backspace')
  g:complementum_keystroke_backspace = "\<BS>"
endif
if !exists('g:complementum_keystroke_space')
  g:complementum_keystroke_space = "\<C-]>\<Space>"  # <C-]> trigger abbreviation
endif
if !exists('g:complementum_keystroke_enter')
  g:complementum_keystroke_enter = "\<CR>"
endif
if !exists('g:complementum_keystroke_tab')
  g:complementum_keystroke_tab = "\<Tab>"
endif
if !exists('g:complementum_keystroke_tab_pumvisible')
  g:complementum_keystroke_tab_pumvisible = "\<C-y>"
endif
if !exists('g:complementum_keystroke_omni')
  g:complementum_keystroke_omni = "\<C-x>\<C-o>"
endif

# autoload
import autoload '../autoload/complementum.vim'

# autocmd
augroup complementum_insert
  autocmd!
  autocmd InsertCharPre * {
    if g:complementum_enabled && &buftype == '' && !&autocomplete
      if !pumvisible() && state('m') == ''
        complementum.Complete(&filetype, v:char)
      endif
    endif
  }
augroup END

# dict
augroup complementum_dict
  autocmd!
  autocmd FileType go {
    autocmd BufWritePost <buffer>
    \ if g:complementum_enabled && executable($HOME .. "/.vim/tools/go/gendict-project.sh") |
    \   job_start($HOME .. "/.vim/tools/go/gendict-project.sh") |
    \ endif
  }
augroup END

# tags
augroup complementum_tags
  autocmd!
  autocmd FileType go {
    autocmd BufWritePost <buffer>
    \ if g:complementum_enabled && executable($HOME .. "/.vim/tools/go/gentags-project.sh") |
    \   job_start($HOME .. "/.vim/tools/go/gentags-project.sh") |
    \ endif
  }
augroup END

# command-line mode
# help cmdline-autocompletion
augroup complementum_cmdline
  autocmd!
  # [:/\?]
  autocmd CmdlineEnter : {
    if g:complementum_enabled
      g:complementum_wildmode_save = &wildmode
      g:complementum_wildoptions_save = &wildoptions
      set wildmode=noselect:lastused,full
      set wildoptions=pum  # fuzzy
    endif
  }
  # [:/\?]
  autocmd CmdlineLeave : {
    if g:complementum_enabled
      &wildmode = g:complementum_wildmode_save
      &wildoptions = g:complementum_wildoptions_save
    endif
  }
  # [:/\?]
  autocmd CmdlineChanged : {
    if g:complementum_enabled
      complementum.CmdLineChanged()
      wildtrigger()
    endif
  }
augroup END

# define mappings
nnoremap <silent> <script> <Plug>(complementum-enable) <ScriptCmd>Enable()<CR>
nnoremap <silent> <script> <Plug>(complementum-disable) <ScriptCmd>complementum.Disable()<CR>
nnoremap <silent> <script> <Plug>(complementum-toggle) <ScriptCmd>complementum.Toggle()<CR>
nnoremap <silent> <script> <Plug>(complementum-toggle-default-keystroke)
  \ <ScriptCmd>complementum.ToggleDefaultKeystroke("default_toggle")<CR>
nnoremap <silent> <script> <Plug>(complementum-toggle-default-omni-keystroke)
  \ <ScriptCmd>complementum.ToggleDefaultKeystroke("omni")<CR>
# inoremap <silent> <script> <Plug>(complementum-complete) <ScriptCmd>noautocmd complementum.Complete(&filetype, v:char)<CR>
# inoremap <silent> <script> <Plug>(complementum-tab) <ScriptCmd>complementum.CompleteKey("tab")<CR>
inoremap <silent> <script> <Plug>(complementum-backspace) <ScriptCmd>complementum.CompleteKey("backspace")<CR>
# inoremap <silent> <script> <Plug>(complementum-space) <ScriptCmd>complementum.CompleteKey("space")<CR>
# inoremap <silent> <script> <Plug>(complementum-enter) <ScriptCmd>complementum.CompleteKey("enter")<CR>

# complementum enable
def Enable()
  # if empty(mapcheck("<Tab>", "i"))
  #   inoremap <Tab> <Plug>(complementum-tab)
  # endif
  if empty(mapcheck("<BS>", "i"))
    inoremap <BS> <Plug>(complementum-backspace)
  endif
  # if empty(mapcheck("<Space>", "i"))
  #   inoremap <Space> <Plug>(complementum-space)
  # endif
  # if empty(mapcheck("<CR>", "i"))
  #   inoremap <CR> <Plug>(complementum-enter)
  # endif
  # toggle
  if empty(mapcheck("<leader>tgc", "n"))
    nnoremap <leader>tgc <Plug>(complementum-toggle):echo v:statusmsg<CR>
  endif
  if empty(mapcheck("<leader>tgC", "n"))
    nnoremap <leader>tgC <Plug>(complementum-toggle-default-keystroke):echo v:statusmsg<CR>
  endif
  if empty(mapcheck("<leader>tGC", "n"))
    nnoremap <leader>tGC <Plug>(complementum-toggle-default-omni-keystroke):echo v:statusmsg<CR>
  endif
  # see augroup complementum_cmdline
  if empty(mapcheck("<Up>", "c"))
    cnoremap <expr> <Up> wildmenumode() ? "\<C-e>\<Up>"   : "\<Up>"
  endif
  if empty(mapcheck("<Down>", "c"))
    cnoremap <expr> <Down> wildmenumode() ? "\<C-e>\<Down>" : "\<Down>"
  endif
  if empty(mapcheck("<Left>", "c"))
    cnoremap <expr> <Left> wildmenumode() ? "\<C-e>\<Left>"   : "\<Left>"
  endif
  if empty(mapcheck("<Right>", "c"))
    cnoremap <expr> <Right> wildmenumode() ? "\<C-e>\<Right>" : "\<Right>"
  endif
  g:complementum_enabled = true
enddef

# set mappings
if get(g:, 'complementum_no_mappings') == 0
  Enable()
endif

# set commands
if get(g:, 'complementum_no_commands') == 0
  command! ComplementumEnable execute "normal \<Plug>(complementum-enable)"
  command! ComplementumDisable execute "normal \<Plug>(complementum-disable)"
  command! ComplementumToggle execute "normal \<Plug>(complementum-toggle)"
  command! ComplementumToggleDefaultKeystroke execute "normal \<Plug>(complementum-toggle-default-keystroke)"
  command! ComplementumToggleDefaultOmniKeystroke execute "normal \<Plug>(complementum-toggle-default-omni-keystroke)"
endif
