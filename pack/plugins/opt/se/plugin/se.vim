vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# Se simple explorer

# See also ../../ftplugin/se.vim

# do not read the file if it is already loaded or se is not enabled
if get(g:, 'loaded_se') || !get(g:, 'se_enabled')
  finish
endif
g:loaded_se = true

# global variables
if !exists('g:se_followfile')
  g:se_followfile = false
endif
if !exists('g:se_hiddenfirst')
  g:se_hiddenfirst = false
endif
if !exists('g:se_position')
  g:se_position = "left"
endif
if !exists('g:se_hiddenshow')
  g:se_hiddenshow = true
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
      if g:se_enabled && g:se_followfile && &filetype != "se"
        se.AutoFollowFile(expand('<afile>:p'))
      endif
    }
  augroup END
endif

# define mappings
nnoremap <silent> <script> <Plug>(se-close) <Cmd>close<CR>
nnoremap <silent> <script> <Plug>(se-help) <ScriptCmd>se.Help()<CR>
nnoremap <silent> <script> <Plug>(se-toggle) <ScriptCmd>se.Toggle(expand('%:p'))<CR>
nnoremap <silent> <script> <Plug>(se-toggle-hidden-show) <ScriptCmd>se.ToggleHiddenFiles(getline('.'), "show")<CR>
nnoremap <silent> <script> <Plug>(se-toggle-hidden-position) <ScriptCmd>se.ToggleHiddenFiles(getline('.'), "position")<CR>
nnoremap <silent> <script> <Plug>(se-followfile)
  \ <ScriptCmd>se.FollowFile(fnamemodify(bufname(winbufnr(winnr('#'))), ":p"))<CR>
nnoremap <silent> <script> <Plug>(se-godir-home) <ScriptCmd>se.GoDir(getenv('HOME'))<CR>
nnoremap <silent> <script> <Plug>(se-godir-parent)
  \ <ScriptCmd>b:cwddir = fnamemodify(getcwd(), ":t")<CR>
  \ <ScriptCmd>cursor(1, 1)<CR>
  \ <ScriptCmd>se.GoFile(getline('.'), "edit")<CR>
  \ <ScriptCmd>se.SearchFile(b:cwddir)<CR>
nnoremap <silent> <script> <Plug>(se-gofile-edit) <ScriptCmd>se.GoFile(getline('.'), "edit")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-editk) <ScriptCmd>se.GoFile(getline('.'), "editk")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-pedit) <ScriptCmd>se.GoFile(getline('.'), "pedit")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-split) <ScriptCmd>se.GoFile(getline('.'), "split")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-tabedit) <ScriptCmd>se.GoFile(getline('.'), "tabedit")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-vsplit) <ScriptCmd>se.GoFile(getline('.'), "vsplit")<CR>
nnoremap <silent> <script> <Plug>(se-refresh) <ScriptCmd>se.Refresh(expand('%:p'))<CR>
nnoremap <silent> <script> <Plug>(se-resize-left)
  \ <ScriptCmd>:execute "vertical resize "  .. (g:se_position == 'right' ? '+1' : '-1')<CR>
nnoremap <silent> <script> <Plug>(se-resize-right)
  \ <ScriptCmd>:execute "vertical resize "  .. (g:se_position == 'right' ? '-1' : '+1')<CR>
nnoremap <silent> <script> <Plug>(se-resize-restore)
  \ <ScriptCmd>:execute ":vertical resize " .. g:se_winsize<CR><ScriptCmd>cursor(line('.'), 1)<CR>

# see ../ftplugin/se.vim

# set mappings
if get(g:, 'se_no_mappings') == 0
  if empty(mapcheck("<leader>se", "n"))
    nnoremap <leader>se <Plug>(se-toggle)
  endif
endif

# set commands
if get(g:, 'se_no_commands') == 0
  command! Se execute "normal \<Plug>(se-toggle)"
  command! SeHelp execute "normal \<Plug>(se-help)"
  command! SeToggle execute "normal \<Plug>(se-toggle)"
endif
