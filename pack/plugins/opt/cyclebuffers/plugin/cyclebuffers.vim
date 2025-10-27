vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_cyclebuffers') || !get(g:, 'cyclebuffers_enabled')
  finish
endif
g:loaded_cyclebuffers = true

# global variables
if !exists('g:cyclebuffers_position')
  g:cyclebuffers_position = "bottom"
endif
if !exists('g:cyclebuffers_oldfiles_limit')
  g:cyclebuffers_oldfiles_limit = 0  # 0 (no limit)
endif

# autoload
import autoload '../autoload/cyclebuffers.vim'

# define mappings
nnoremap <silent> <script> <Plug>(cyclebuffers-close) <Cmd>close \| pclose<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-close-pedit) <ScriptCmd>cyclebuffers.ClosePreview()<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-help) <ScriptCmd>cyclebuffers.Help()<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-cycle) <ScriptCmd>cyclebuffers.Cycle()<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-oldfiles) <ScriptCmd>cyclebuffers.CycleOldFiles()<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-delete) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "delete")<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-delete-keep) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "delete-keep")<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-wipe) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "wipe")<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-wipe-keep) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "wipe-keep")<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-edit) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "edit")<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-pedit) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "pedit")<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-split) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "split")<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-vsplit) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "vsplit")<CR>
nnoremap <silent> <script> <Plug>(cyclebuffers-select-tabedit) <ScriptCmd>cyclebuffers.SelectBuffer(line('.'), "tabedit")<CR>

# set mappings
if get(g:, 'cyclebuffers_no_mappings') == 0
  if empty(mapcheck("<leader><Space>", "n"))
    nnoremap <leader><Space> <Plug>(cyclebuffers-cycle)
  endif
endif

# set commands
if get(g:, 'cyclebuffers_no_commands') == 0
  command! CycleBuffers execute "normal \<Plug>(cyclebuffers-cycle)"
  command! CycleOldFiles execute "normal \<Plug>(cyclebuffers-oldfiles)"
endif
