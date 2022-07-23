vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# Se simple explorer

# See also ../../ftplugin/se.vim

# do not read the file if it is already loaded or se is not enabled
if exists('g:loaded_se') || !get(g:, 'se_enabled') || &cp
  finish
endif
g:loaded_se = 1

# global variables
if !exists('g:se_winsize')
  g:se_winsize = 20
endif

# autoload
import autoload '../autoload/se.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(se-close) <Cmd>close<CR>
nnoremap <silent> <unique> <script> <Plug>(se-help) <ScriptCmd>se.Help()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-toggle) <ScriptCmd>se.Toggle()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-followfile) <ScriptCmd>se.FollowFile()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-edit) <ScriptCmd>se.Gofile("edit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-editk) <ScriptCmd>se.Gofile("editk")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-pedit) <ScriptCmd>se.Gofile("pedit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-split) <ScriptCmd>se.Gofile("split")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-tabedit) <ScriptCmd>se.Gofile("tabedit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-vsplit) <ScriptCmd>se.Gofile("vsplit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-refreshlist) <ScriptCmd>se.RefreshList()<CR>

# see ../ftplugin/se.vim
# set mappings
if get(g:, 'se_no_mappings') == 0
  if empty(mapcheck("<leader>se", "n"))
    nnoremap <leader>se <Plug>(se-toggle)
  endif
  command! SeHelp se.Help()
  command! SeToggle se.Toggle()
endif
