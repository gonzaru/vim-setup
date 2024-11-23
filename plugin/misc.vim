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
if get(g:, 'loaded_misc') || !get(g:, 'misc_enabled')
  finish
endif
g:loaded_misc = true

# autoload
import autoload '../autoload/misc.vim'

# go to last edit cursor position
def GoLastEditCursorPos()
  var nline = line("'\"")
  if nline >= 1 && nline <= line("$") && &filetype !~ "commit"
     && index(['xxd', 'gitrebase'], &filetype) == -1
    execute "normal! g`\""
  endif
enddef

# check trailing spaces
def CheckTrailingSpaces()
  var nline: number
  nline = search('\s\+$', 'n')
  if nline > 0
    utils#EchoWarningMsg($"Warning: there are trailing spaces in the line '{nline}'")
  endif
enddef

# autocmd
augroup misc_golasteditcursor
  autocmd!
  autocmd BufReadPost * {
    if g:misc_enabled
      GoLastEditCursorPos()
    endif
  }
augroup END

augroup misc_checktrailingspaces
  autocmd!
  autocmd BufWinEnter,BufWritePost * {
    if g:misc_enabled && index(['help', 'git', 'gitscm', 'qf'], &filetype) == -1 && &buftype != 'terminal'
      CheckTrailingSpaces()
    endif
  }
augroup END

# define mappings
nnoremap <silent> <script> <Plug>(misc-golasteditcursor) <ScriptCmd>GoLastEditCursorPos()<CR>
# inoremap <silent> <script> <Plug>(misc-mapinsertenter) <ScriptCmd>misc.MapInsertEnter()<CR>
# inoremap <silent> <script> <Plug>(misc-mapinserttab) <ScriptCmd>misc.MapInsertTab()<CR>
nnoremap <silent> <script> <Plug>(misc-checktrailingspaces) <ScriptCmd>CheckTrailingSpaces()<CR>

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
  command! MiscCheckTrailingSpaces CheckTrailingSpaces()
  command! MiscDiffToggle misc.DiffToggle()
  command! MiscFoldColumnToggle misc.FoldColumnToggle()
  command! MiscFoldToggle misc.FoldToggle()
  command! MiscGoLastEditCursor GoLastEditCursorPos()
  command! MiscGuiMenuBarToggle misc.GuiMenuBarToggle()
  command! MiscMapInsertEnter misc.MapInsertEnter()
  command! MiscMapInsertTab misc.MapInsertTab()
  command! MiscMenuLanguageSpell misc.MenuLanguageSpell()
  command! MiscMenuMisc misc.MenuMisc()
  command! MiscPythonDynamic misc.SetPythonDynamic()
  command! -nargs=1 MiscRegisterDelete misc.RegisterDelete('<args>')
  command! MiscRegisterDeleteAll misc.RegisterDeleteAll()
  command! -nargs=1 -complete=customlist,misc#CompleteReloadPluginPack MiscReloadPluginOpt {
    misc.ReloadPluginPack(<f-args>, "opt")
  }
  command! -nargs=1 -complete=customlist,misc#CompleteReloadPluginPack MiscReloadPluginStart {
    misc.ReloadPluginPack(<f-args>, "start")
  }
  command! MiscSH misc.SH()
  command! MiscSetMaxFoldLevel misc.SetMaxFoldLevel()
  command! MiscSetPythonDynamic misc.SetPythonDynamic()
  command! MiscSignColumnToggle misc.SignColumnToggle()
  command! MiscSyntaxToggle misc.SyntaxToggle()
  command! MiscTerminalColorsChange {
    highlight! Terminal guifg=#f4f4f4 guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
    highlight! StatusLineTerm guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
    highlight! link StatusLineTermNC StatusLineNC
  }
  command! MiscTerminalColorsRestore {
    highlight! link Terminal Normal
    highlight! link StatusLineTerm StatusLine
    highlight! link StatusLineTermNC StatusLineNC
  }
endif
