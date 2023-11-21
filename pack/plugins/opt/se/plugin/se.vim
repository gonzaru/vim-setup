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
nnoremap <silent> <unique> <script> <Plug>(se-toggle) <ScriptCmd>se.Toggle(expand('%:p'))<CR>
nnoremap <silent> <unique> <script> <Plug>(se-toggle-hidden)
  \ <ScriptCmd>b:selfile = substitute(getline('.'), '[/@\*\|=]$', '', '')<CR>
  \ <ScriptCmd>g:se_hiddenfirst = !g:se_hiddenfirst<CR>
  \ <ScriptCmd>se.Refresh(expand('%:p'))<CR>
  \ <ScriptCmd>cursor(3, 1)<CR>
  \ <ScriptCmd>se.SearchFile(b:selfile)<CR>
nnoremap <silent> <unique> <script> <Plug>(se-followfile)
  \ <ScriptCmd>se.FollowFile(fnamemodify(bufname(winbufnr(winnr('#'))), ":p"))<CR>
nnoremap <silent> <unique> <script> <Plug>(se-godir-home) <ScriptCmd>se.GoDir(getenv('HOME'))<CR>
nnoremap <silent> <unique> <script> <Plug>(se-godir-parent)
  \ <ScriptCmd>b:cwddir = fnamemodify(getcwd(), ":t")<CR>
  \ <ScriptCmd>cursor(1, 1)<CR>
  \ <ScriptCmd>se.GoFile(getline('.'), "edit")<CR>
  \ <ScriptCmd>se.SearchFile(b:cwddir)<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-edit) <ScriptCmd>se.GoFile(getline('.'), "edit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-editk) <ScriptCmd>se.GoFile(getline('.'), "editk")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-pedit) <ScriptCmd>se.GoFile(getline('.'), "pedit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-split) <ScriptCmd>se.GoFile(getline('.'), "split")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-tabedit) <ScriptCmd>se.GoFile(getline('.'), "tabedit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-gofile-vsplit) <ScriptCmd>se.GoFile(getline('.'), "vsplit")<CR>
nnoremap <silent> <unique> <script> <Plug>(se-refresh) <ScriptCmd>se.Refresh(expand('%:p'))<CR>

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
  command! SeToggle se.Toggle(expand('%:p'))
endif
