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
  g:complementum_minchars = 2
endif
if !exists('g:complementum_typedchars')
  g:complementum_typedchars = 0
endif
if !exists('g:complementum_keystroke_default')
  g:complementum_keystroke_default = "\<C-n>"
endif
if !exists('g:complementum_keystroke_backspace')
  g:complementum_keystroke_backspace = "\<Backspace>"
endif
if !exists('g:complementum_keystroke_space')
  g:complementum_keystroke_space = "\<Space>"
endif
if !exists('g:complementum_keystroke_enter')
  g:complementum_keystroke_enter = "\<CR>"
endif
if !exists('g:complementum_keystroke_tab')
  g:complementum_keystroke_tab = "\<Tab>"
endif
if !exists('g:complementum_keystroke_go')
  g:complementum_keystroke_go = "\<C-x>\<C-o>"
endif

# autoload
import autoload '../autoload/complementum.vim'

# autocmd
augroup complementum_insert
  autocmd!
  autocmd InsertEnter,InsertLeave,CompleteDone * g:complementum_typedchars = 0
  autocmd InsertCharPre * {
    if g:complementum_enabled && !pumvisible() && state('m') == ''
      noautocmd complementum.Complete(&filetype)
    else
      g:complementum_typedchars = 0
    endif
  }
augroup END

# define mappings
nnoremap <silent> <script> <Plug>(complementum-enable) <ScriptCmd>complementum.Enable()<CR>
nnoremap <silent> <script> <Plug>(complementum-disable) <ScriptCmd>complementum.Disable()<CR>
nnoremap <silent> <script> <Plug>(complementum-toggle) <ScriptCmd>complementum.Toggle()<CR>
inoremap <silent> <script> <Plug>(complementum-complete) <ScriptCmd>noautocmd complementum.Complete(&filetype)<CR>
inoremap <silent> <script> <Plug>(complementum-tab) <ScriptCmd>complementum.CompleteKey("tab")<CR>
inoremap <silent> <script> <Plug>(complementum-backspace) <ScriptCmd>complementum.CompleteKey("backspace")<CR>
inoremap <silent> <script> <Plug>(complementum-space) <ScriptCmd>complementum.CompleteKey("space")<CR>
inoremap <silent> <script> <Plug>(complementum-enter) <ScriptCmd>complementum.CompleteKey("enter")<CR>

# set mappings
if get(g:, 'complementum_no_mappings') == 0
  complementum.Enable()
endif

# set commands
if get(g:, 'complementum_no_commands') == 0
  command! ComplementumEnable execute "normal \<Plug>(complementum-enable)"
  command! ComplementumDisable execute "normal \<Plug>(complementum-disable)"
  command! ComplementumToggle execute "normal \<Plug>(complementum-toggle)"
endif
