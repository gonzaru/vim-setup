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
if !exists('g:se_fileignore')
  # do not list these patterns
  g:se_fileignore = "*.o,*.obj,*.pyc,*.swp"
endif
if !exists('g:se_followfile')
  g:se_followfile = false
endif
if !exists('g:se_hiddenfirst')
  g:se_hiddenfirst = false
endif
if !exists('g:se_hiddenshow')
  g:se_hiddenshow = false
endif
if !exists('g:se_opentool')
  g:se_opentool = "xdg-open"
endif
if !exists('g:se_position')
  g:se_position = "left"
endif
if !exists('g:se_prevdirhist')
  g:se_prevdirhist = 50
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
nnoremap <silent> <script> <Plug>(se-godir-home) <ScriptCmd>se.GoDirHome()<CR>
nnoremap <silent> <script> <Plug>(se-godir-parent) <ScriptCmd>se.GoDirParent()<CR>
nnoremap <silent> <script> <Plug>(se-godir-prev) <ScriptCmd>se.GoDirPrev()<CR>
nnoremap <silent> <script> <Plug>(se-godir-prompt) <ScriptCmd>se.GoDirPrompt()<CR>
nnoremap <silent> <script> <Plug>(se-gofile-edit) <ScriptCmd>se.GoFile(getline('.'), "edit")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-editk) <ScriptCmd>se.GoFile(getline('.'), "editk")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-pedit) <ScriptCmd>se.GoFile(getline('.'), "pedit")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-split) <ScriptCmd>se.GoFile(getline('.'), "split")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-tabedit) <ScriptCmd>se.GoFile(getline('.'), "tabedit")<CR>
nnoremap <silent> <script> <Plug>(se-gofile-vsplit) <ScriptCmd>se.GoFile(getline('.'), "vsplit")<CR>
nnoremap <silent> <script> <Plug>(se-check-mime) <ScriptCmd>se.CheckMimeType(getline('.'))<CR>
nnoremap <silent> <script> <Plug>(se-set-mime) <ScriptCmd>se.SetMimeType(getline('.'))<CR>
nnoremap <silent> <script> <Plug>(se-open-with-default) <ScriptCmd>se.OpenWith(getline('.'), true)<CR>
nnoremap <silent> <script> <Plug>(se-open-with-custom) <ScriptCmd>se.OpenWith(getline('.'), false)<CR>
nnoremap <silent> <script> <Plug>(se-refresh) <ScriptCmd>se.Refresh(expand('%:p'))<CR>
nnoremap <silent> <script> <Plug>(se-resize-left) <ScriptCmd>se.Resize("left")<CR>
nnoremap <silent> <script> <Plug>(se-resize-right) <ScriptCmd>se.Resize("right")<CR>
nnoremap <silent> <script> <Plug>(se-resize-restore) <ScriptCmd>se.Resize("restore")<CR>
nnoremap <silent> <script> <Plug>(se-resize-maxcol) <ScriptCmd>se.Resize("maxcol")<CR>

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
