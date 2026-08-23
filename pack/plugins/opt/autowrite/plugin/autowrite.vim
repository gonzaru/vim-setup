vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_autowrite') || !get(g:, 'autowrite_enabled')
  finish
endif
g:loaded_autowrite = true

# global variables
if !exists('g:autowrite_autodelay')
  g:autowrite_autodelay = 300  # ms
endif
if !exists('g:autowrite_mode')
  g:autowrite_mode = 'soft'
endif

# autoload
import autoload '../autoload/autowrite.vim'

# autowrite events
var _timer = -1
augroup autowrite_events
  autocmd!

  # see 'updatetime'
  autocmd CursorHold,CursorHoldI *  {
    if g:autowrite_enabled
      if reg_recording() == '' && &buftype == '' && &l:modifiable && !empty(bufname('%')) && !&l:readonly
        timer_stop(_timer)
        # g:autowrite_autodelay + &updatetime
        _timer = timer_start(g:autowrite_autodelay, (_) => execute('silent! update'))
      else
        timer_stop(_timer)
        _timer = -1
      endif
    endif
  }

  autocmd CursorMoved,CursorMovedI * {
    if g:autowrite_enabled
      if _timer != -1
        timer_stop(_timer)
        _timer = -1
      endif
    endif
  }

augroup END

# define mappings
nnoremap <silent> <script> <Plug>(autowrite-enable) <ScriptCmd>autowrite.Enable()<CR>
nnoremap <silent> <script> <Plug>(autowrite-disable) <ScriptCmd>autowrite.Disable()<CR>
nnoremap <silent> <script> <Plug>(autowrite-toggle) <ScriptCmd>autowrite.Toggle()<CR>

# TODO
# set mappings
# if !get(g:, 'autowrite_no_mappings')
#   if empty(mapcheck("<leader>ae", "n"))
#     nnoremap <leader>ae <Plug>(autowrite-enable)
#   endif
#   if empty(mapcheck("<leader>ad", "n"))
#     nnoremap <leader>ad <Plug>(autowrite-disable)
#   endif
#   if empty(mapcheck("<leader>at", "n"))
#     nnoremap <leader>at <Plug>(autowrite-toggle)
#   endif
# endif

# set commands
if !get(g:, 'autowrite_no_commands')
  command! AutoWriteEnable execute "normal \<Plug>(autowrite-enable)"
  command! AutoWriteDisable execute "normal \<Plug>(autowrite-disable)"
  command! AutoWriteToggle execute "normal \<Plug>(autowrite-toggle)"
endif
