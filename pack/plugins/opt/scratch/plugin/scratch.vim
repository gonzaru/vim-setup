vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_scratch') || !get(g:, 'scratch_enabled') || &cp
  finish
endif
g:loaded_scratch = 1

# autoload
import autoload '../autoload/scratch.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(scratch-buffer) <ScriptCmd>scratch.Buffer()<CR>
nnoremap <silent> <unique> <script> <Plug>(scratch-terminal) <ScriptCmd>scratch.Terminal()<CR>

# set mappings
if get(g:, 'scratch_no_mappings') == 0
  if empty(mapcheck("<leader>s<BS>", "n"))
    nnoremap <silent><leader>s<BS> <Plug>(scratch-buffer)
  endif
  if empty(mapcheck("<leader>s<CR>", "n"))
    nnoremap <silent><leader>s<CR> <Plug>(scratch-terminal)
  endif
  if empty(mapcheck("<leader>sc", "n"))
    nnoremap <silent><leader>sc <Plug>(scratch-buffer)
  endif
  if empty(mapcheck("<leader>sz", "n"))
    nnoremap <silent><leader>sz <Plug>(scratch-terminal)
  endif
endif

# set commands
if get(g:, 'scratch_no_commands') == 0
  command! ScratchBuffer scratch.Buffer()
  command! ScratchTerminal scratch.Terminal()
endif
