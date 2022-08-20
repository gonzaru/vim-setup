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
if !exists('g:se_followfile')
  g:se_followfile = 0
endif
if !exists('g:se_hiddenfirst')
  g:se_hiddenfirst = 0
endif
if !exists('g:se_position')
  g:se_position = "left"
endif
if !exists('g:se_winsize')
  g:se_winsize = 20
endif

# autoload
import autoload '../autoload/se.vim'

# autocmd
if get(g:, 'se_followfile')
  augroup se_followfile
    autocmd!
    autocmd BufWinEnter * {
      if get(g:, 'se_followfile') && &filetype != "se"
        se.AutoFollowFile(expand('<afile>:p'))
      endif
    }
  augroup END
endif

# define mappings
nnoremap <silent> <unique> <script> <Plug>(se-close) <Cmd>close<CR>
nnoremap <silent> <unique> <script> <Plug>(se-help) <ScriptCmd>se.Help()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-toggle) <ScriptCmd>se.Toggle()<CR>
nnoremap <silent> <unique> <script> <Plug>(se-followfile)
  \ <ScriptCmd>se.FollowFile(fnamemodify(bufname(winbufnr(winnr('#'))), ":p"))<CR>
nnoremap <silent> <unique> <script> <Plug>(se-godir-home) <ScriptCmd>se.GoDir(getenv('HOME'))<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-edit) <ScriptCmd>se.GoFile("edit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-editk) <ScriptCmd>se.GoFile("editk")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-pedit) <ScriptCmd>se.GoFile("pedit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-split) <ScriptCmd>se.GoFile("split")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-tabedit) <ScriptCmd>se.GoFile("tabedit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-vsplit) <ScriptCmd>se.GoFile("vsplit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-refresh) <ScriptCmd>se.Refresh()<CR>

# see ../ftplugin/se.vim

# set mappings
if get(g:, 'se_no_mappings') == 0
  if empty(mapcheck("<leader>se", "n"))
    nnoremap <leader>se <Plug>(se-toggle)
  endif
endif

# set commands
if get(g:, 'se_no_commands') == 0
  command! SeHelp se.Help()
  command! SeToggle se.Toggle()
endif
