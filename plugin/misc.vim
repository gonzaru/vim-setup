vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# g: global variables
# b: local buffer variables
# w: local window variables
# t: local tab page variables
# s: script-local variables
# l: local function variables
# v: Vim variables.

# do not read the file if it is already loaded
if exists('g:loaded_misc') || !get(g:, 'misc_enabled')
  finish
endif
g:loaded_misc = true

# autoload
import autoload '../autoload/misc.vim'

# autocmd
augroup misc_golasteditcursor
  autocmd!
  autocmd BufReadPost * {
    if g:misc_enabled
      misc.GoLastEditCursorPos()
    endif
  }
augroup END

augroup misc_checktrailingspaces
  autocmd!
  autocmd BufWinEnter,BufWritePost * {
    if g:misc_enabled && &filetype != 'help'
      misc.CheckTrailingSpaces()
    endif
  }
augroup END

# define mappings
nnoremap <silent> <unique> <script> <Plug>(misc-golasteditcursor) <ScriptCmd>misc.GoLastEditCursorPos()<CR>
inoremap <silent> <unique> <script> <Plug>(misc-mapinsertenter) <ScriptCmd>misc.MapInsertEnter()<CR>
inoremap <silent> <unique> <script> <Plug>(misc-mapinserttab) <ScriptCmd>misc.MapInsertTab()<CR>
nnoremap <silent> <unique> <script> <Plug>(misc-checktrailingspaces) <ScriptCmd>misc.CheckTrailingSpaces()<CR>

# TODO:
# set mappings
# if get(g:, 'misc_no_mappings') == 0
# endif

# set commands
if get(g:, 'misc_no_commands') == 0
  command! -nargs=1 -complete=buffer MiscEditTopBuffer misc.EditTop(<f-args>)
  command! -nargs=1 -complete=file MiscEditTopFile misc.EditTop(<f-args>)
  command! -nargs=1 MiscGoBufferPos misc.GoBufferPos(str2nr(<f-args>))
  command! MiscBackGroundToggle misc.BackgroundToggle()
  command! MiscDiffToggle misc.DiffToggle()
  command! MiscFoldColumnToggle misc.FoldColumnToggle()
  command! MiscFoldToggle misc.FoldToggle()
  command! MiscGoLastEditCursor misc.GoLastEditCursorPos()
  command! MiscGuiMenuBarToggle misc.GuiMenuBarToggle()
  command! MiscMapInsertEnter misc.MapInsertEnter()
  command! MiscMapInsertTab misc.MapInsertTab()
  command! MiscMenuLanguageSpell misc.MenuLanguageSpell()
  command! MiscMenuMisc misc.MenuMisc()
  command! MiscSH misc.SH()
  command! MiscSetMaxFoldLevel misc.SetMaxFoldLevel()
  command! MiscCheckTrailingSpaces misc.CheckTrailingSpaces()
  command! MiscSignColumnToggle misc.SignColumnToggle()
  command! MiscSyntaxToggle misc.SyntaxToggle()
endif
