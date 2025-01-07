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
  g:complementum_minchars = 3  # >= 1
endif
if !exists('g:complementum_omnichars')
  g:complementum_omnichars = {
    'python': ["."],
    'go': ["."],
    'c': [".", "#"],
  }
endif
if !exists('g:complementum_omnifuncs')
  g:complementum_omnifuncs = {
    'python': ["python3complete#Complete", "g:LspOmniFunc"],
    'go': ["go#complete#Complete", "g:LspOmniFunc"],
    'c': ["ccomplete#Complete", "g:LspOmniFunc"]
  }
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
def CheckInsertCharPre()
  if !pumvisible() && state('m') == ''
    noautocmd complementum.Complete(&filetype, v:char)
  endif
enddef
augroup complementum_insert
  autocmd!
  autocmd InsertCharPre * {
    if g:complementum_enabled
      CheckInsertCharPre()
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
# inoremap <silent> <script> <Plug>(complementum-backspace) <ScriptCmd>complementum.CompleteKey("backspace")<CR>
# inoremap <silent> <script> <Plug>(complementum-space) <ScriptCmd>complementum.CompleteKey("space")<CR>
# inoremap <silent> <script> <Plug>(complementum-enter) <ScriptCmd>complementum.CompleteKey("enter")<CR>

# complementum enable
def Enable()
  # if empty(mapcheck("<Tab>", "i"))
  #   inoremap <Tab> <Plug>(complementum-tab)
  # endif
  # if empty(mapcheck("<BS>", "i"))
  #   inoremap <BS> <Plug>(complementum-backspace)
  # endif
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
