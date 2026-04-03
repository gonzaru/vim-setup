vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_viewmode') || !get(g:, 'viewmode_enabled')
  finish
endif
g:loaded_viewmode = true

# global variables
if !exists('g:viewmode_auto_readonly')
  g:viewmode_auto_readonly = false
endif

# autoload
import autoload '../autoload/viewmode.vim'

# autocmd
augroup viewmode_readonly
  autocmd!
  # :set readonly
  autocmd OptionSet readonly {
    if g:viewmode_auto_readonly
      if v:option_new == "1"
        viewmode.Enable()
      else
        viewmode.Disable()
      endif
    endif
  }
augroup END

# define mappings
nnoremap <silent> <script> <Plug>(viewmode-enable) <ScriptCmd>viewmode.Enable()<CR>
nnoremap <silent> <script> <Plug>(viewmode-disable) <ScriptCmd>viewmode.Disable()<CR>
nnoremap <silent> <script> <Plug>(viewmode-toggle) <ScriptCmd>viewmode.Toggle()<CR>
nnoremap <silent> <script> <Plug>(viewmode-help) <ScriptCmd>viewmode.Help()<CR>

# set mappings
if get(g:, 'viewmode_no_mappings') == 0
  if empty(mapcheck("<leader>we", "n"))
    nnoremap <leader>we <Plug>(viewmode-enable)
  endif
  if empty(mapcheck("<leader>wd", "n"))
    nnoremap <leader>wd <Plug>(viewmode-disable)
  endif
  if empty(mapcheck("<leader>wt", "n"))
    nnoremap <leader>wt <Plug>(viewmode-toggle)
  endif
  if empty(mapcheck("<leader>wh", "n"))
    nnoremap <leader>wh <Plug>(viewmode-help)
  endif
endif

# set commands
if get(g:, 'viewmode_no_commands') == 0
  command! ViewModeEnable execute "normal \<Plug>(viewmode-enable)"
  command! ViewModeDisable execute "normal \<Plug>(viewmode-disable)"
  command! ViewModeToggle execute "normal \<Plug>(viewmode-toggle)"
endif
