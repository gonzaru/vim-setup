vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_xkb') || !get(g:, 'xkb_enabled')
  finish
endif
g:loaded_xkb = true

# global variables
if !exists('g:xkb_layout_first')
  g:xkb_layout_first = ""  # default empty
endif
if !exists('g:xkb_layout_next')
  g:xkb_layout_next = ""  # default empty
endif
if !exists('g:xkb_layout_current')
  g:xkb_layout_current = g:xkb_layout_first
endif
if !exists('g:xkb_cmd_layout_first')
  g:xkb_cmd_layout_first = !empty(g:xkb_layout_first) ? ["setxkbsw", "-s", g:xkb_layout_first] : []
endif
if !exists('g:xkb_cmd_layout_next')
  g:xkb_cmd_layout_next = !empty(g:xkb_layout_next) ? ["setxkbsw", "-s", g:xkb_layout_next] : []
endif
if !exists('g:xkb_debug_file')
  g:xkb_debug_file = $"/tmp/{$USER}-{has('gui_running') ? 'vim-gui' : 'vim'}-xkb_events-{getpid()}.log"
endif
if !exists('g:xkb_debug_info')
  g:xkb_debug_info = false
endif

# disable plugin
if empty($DISPLAY) || (!has('gui_running') && empty(&t_fe))
|| empty(g:xkb_layout_first) || empty(g:xkb_layout_next)
|| !executable(g:xkb_cmd_layout_first[0]) || !executable(g:xkb_cmd_layout_next[0])
  g:xkb_enabled = false
  finish
endif

# autoload
import autoload '../autoload/xkb.vim'

# xkb events
augroup xkb_events
  autocmd!
  autocmd VimEnter * ++once {
    if g:xkb_enabled
      if g:xkb_debug_info && filewritable(g:xkb_debug_file)
        delete(g:xkb_debug_file)
      endif
      if !has('gui_running')
        xkb.Layout(["VimEnter"], "next", "job")
      endif
    endif
  }
  autocmd VimLeavePre * ++once {
    if g:xkb_enabled
      xkb.Layout(["VimLeavePre"], "first", "shell")
    endif
  }
  autocmd VimResume * {
    if g:xkb_enabled
      if !has('gui_running')
        xkb.Layout(["VimResume"], "next", "job")
      endif
    endif
  }
  autocmd VimSuspend * {
    if g:xkb_enabled
      if !has('gui_running')
        xkb.Layout(["VimSuspend"], "first", "job")
      endif
    endif
  }
  autocmd FocusGained * {
    if g:xkb_enabled
      xkb.Layout(["FocusGained"], "next", "job")
    endif
  }
  autocmd FocusLost * {
    if g:xkb_enabled
      xkb.Layout(["FocusLost"], "first", "shell")
    endif
  }
augroup END

# define mappings
nnoremap <silent> <script> <Plug>(xkb-layout-first) <ScriptCmd>xkb.Layout([], "first", "job")<CR>
nnoremap <silent> <script> <Plug>(xkb-layout-next) <ScriptCmd>xkb.Layout([], "next", "job")<CR>
nnoremap <silent> <script> <Plug>(xkb-toggle-layout) <ScriptCmd>xkb.ToggleLayout()<CR>

# set mappings
if get(g:, 'xkb_no_mappings') == 0
  if empty(mapcheck("<leader>xt", "n"))
    nnoremap <leader>xt <Plug>(xkb-toggle-layout)
  endif
endif

# set commands
if get(g:, 'xkb_no_commands') == 0
  command! XKBLayoutFirst execute "normal \<Plug>(xkb-layout-first)"
  command! XKBLayoutNext execute "normal \<Plug>(xkb-layout-next)"
  command! XKBToggleLayout execute "normal \<Plug>(xkb-toggle-layout)"
endif
