vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# g:  global variables
# b:  local buffer variables
# w:  local window variables
# t:  local tab page variables
# s:  script-local variables
# l:  local function variables
# v:  Vim variables.

# do not read the file if it is already loaded
if exists('g:loaded_misc') || !get(g:, 'misc_enabled') || &cp
  finish
endif
g:loaded_misc = 1

# autoload
import autoload '../autoload/misc.vim'

# go to last edit cursor position
def GoLastEditCursorPos()
  var lastcursorline = line("'\"")
  if lastcursorline >= 1 && lastcursorline <= line("$") && &ft !~ "commit"
    execute "normal! g`\""
  endif
enddef

# define mappings
nnoremap <silent> <unique> <script> <Plug>(misc-golasteditcursor) <ScriptCmd><SID>GoLastEditCursorPos()<CR>
nnoremap <silent> <unique> <script> <Plug>(misc-doc) <ScriptCmd>misc.Doc(&filetype)<CR>

# TODO:
# set mappings
# if get(g:, 'misc_no_mappings') == 0
# endif

# set commands
if get(g:, 'misc_no_commands') == 0
  command! -nargs=1 -complete=file -complete=buffer MiscEditTop misc.EditTop(<f-args>)
  command! -nargs=1 MiscGoBufferPos misc.GoBufferPos(str2nr(<f-args>))
  command! MiscBackGroundToggle misc.BackgroundToggle()
  command! MiscDiffToggle misc.DiffToggle()
  command! MiscDoc misc.Doc(&filetype)
  command! MiscFoldColumnToggle misc.FoldColumnToggle()
  command! MiscFoldToggle misc.FoldToggle()
  command! MiscGoLastEditCursor GoLastEditCursorPos()
  command! MiscGuiMenuBarToggle misc.GuiMenuBarToggle()
  command! MiscMenuLanguageSpell misc.MenuLanguageSpell()
  command! MiscMenuMisc misc.MenuMisc()
  command! MiscSH misc.SH()
  command! MiscSetMaxFoldLevel misc.SetMaxFoldLevel()
  command! MiscSignColumnToggle misc.SignColumnToggle()
  command! MiscSyntaxToggle misc.SyntaxToggle()
endif
