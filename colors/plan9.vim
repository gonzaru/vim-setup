vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# My plan9 theme :)

# do not read the file if it is already loaded
if get(g:, 'loaded_plan9') && get(g:, 'colors_name', '') == "plan9"
  finish
endif
g:loaded_plan9 = true

# number of colors
if !has('gui_running') && str2nr(&t_Co) < 256
  finish
endif

# light background
set background=light

# clean up
highlight clear
if exists("syntax_on")
  syntax reset
endif

# colorscheme
g:colors_name = "plan9"

# global variables
if !exists('g:plan9_style')
  g:plan9_style = "light"  # only light
endif

# colors
const termgui = has('termguicolors') && &termguicolors
const colors = {
  'normal': {
    'guifg': 'black',
    'guibg': '#ffffd7',
    'ctermfg': 'black',
    'ctermbg': 230
  }
}

execute $"highlight! Normal guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! MatchParen guifg={colors.normal.guifg} guibg=#afaf87 ctermfg={colors.normal.ctermfg} ctermbg=144 gui=NONE cterm=NONE term=NONE"

execute $"highlight! Visual guifg={colors.normal.guifg} guibg=#ffffaf ctermfg={colors.normal.ctermfg} ctermbg=229 gui=NONE cterm=NONE term=NONE"

# TODO
# VisualNOS

execute $"highlight! WildMenu guifg={colors.normal.guifg} guibg=#ffffaf ctermfg={colors.normal.ctermfg} ctermbg=229 gui=NONE cterm=NONE term=NONE"

# statusline
execute $"highlight! StatusLine guifg={colors.normal.guifg} guibg=#d7d7af ctermfg={colors.normal.ctermfg} ctermbg={termgui ? 187 : 186} gui=NONE cterm=NONE term=NONE"
execute $"highlight! StatusLineNC guifg={colors.normal.guifg} guibg=#dedebd ctermfg={colors.normal.ctermfg} ctermbg={termgui ? 187 : 144} gui=NONE cterm=NONE term=NONE"

# vertical split color
execute $"highlight! VertSplit guifg={colors.normal.guifg} guibg=#dedebd ctermfg={colors.normal.ctermfg} ctermbg={termgui ? 187 : 144} gui=NONE cterm=NONE term=NONE"

# execute $"highlight! Cursor guifg=white guibg={colors.normal.guifg} gui=NONE cterm=NONE term=NONE"
# highlight! Cursor guifg=white guibg=#8888cc gui=NONE cterm=NONE term=NONE
highlight! Cursor guifg=white guibg=#606060 gui=NONE cterm=NONE term=NONE
# language keymap cursor (i_CTRL-^)
highlight! link lCursor Cursor
highlight! CursorLine guifg=NONE guibg=#eeeec7 ctermfg=NONE ctermbg=187 gui=NONE cterm=NONE term=NONE
execute $"highlight! CursorLineNR guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"
highlight! link CursorColumn CursorLine

# current quickfix item
highlight! link QuickFixLine PmenuSel

# TODO
# ToolbarLine
# ToolbarButton

execute $"highlight! ColorColumn guifg={colors.normal.guifg} guibg=#ffd75f ctermfg={colors.normal.ctermfg} ctermbg=221 gui=NONE cterm=NONE term=NONE"

# spell/diagnostics: SpellBad = error, SpellRare = warning
execute $"highlight! SpellBad guifg={colors.normal.guifg} guibg=#ff8787 ctermfg={colors.normal.ctermfg} ctermbg=210 gui=NONE cterm=NONE term=NONE"
execute $"highlight! SpellRare guifg=pink guibg=#ff8787 ctermfg={colors.normal.ctermfg} ctermbg=210 gui=underline cterm=underline term=NONE"
execute $"highlight! SpellCap guifg={colors.normal.guifg} guibg=#d7ffff ctermfg={colors.normal.ctermfg} ctermbg=195 gui=underline cterm=underline term=NONE"
highlight! link SpellLocal SpellRare

execute $"highlight! Search guifg={colors.normal.guifg} guibg=#ffffaf ctermfg={colors.normal.ctermfg} ctermbg=229 gui=NONE cterm=NONE term=NONE"
highlight! link CurSearch Search
highlight! link IncSearch Search

execute $"highlight! LineNr guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"
highlight! link LineNrAbove LineNr
highlight! link LineNrBelow LineNr

highlight! SpecialKey guifg=#d70000 guibg=NONE ctermfg=160 ctermbg=NONE gui=NONE cterm=NONE term=NONE

# diff (diffthis)
execute $"highlight! DiffText guifg={colors.normal.guifg} guibg=#afafff ctermfg={colors.normal.ctermfg} ctermbg=147 gui=NONE cterm=NONE term=NONE"
execute $"highlight! DiffChange guifg={colors.normal.guifg} guibg=#d7ffff ctermfg={colors.normal.ctermfg} ctermbg=195 gui=NONE cterm=NONE term=NONE"
execute $"highlight! DiffDelete guifg={colors.normal.guifg} guibg=#ff8787 ctermfg={colors.normal.ctermfg} ctermbg=210 gui=NONE cterm=NONE term=NONE"
execute $"highlight! DiffAdd guifg={colors.normal.guifg} guibg=#afffaf ctermfg={colors.normal.ctermfg} ctermbg=157 gui=NONE cterm=NONE term=NONE"

# git
highlight! link diffAdded Normal
highlight! link diffChanged Normal
highlight! link diffFile Normal
highlight! link diffIndexLine Normal
highlight! link diffLine Normal
highlight! link diffNewFile Normal
highlight! link diffOldFile Normal
highlight! link diffRemoved Normal
highlight! link diffSubname Normal

execute $"highlight! Conceal guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"

# TODO ~ (new buffer)
execute $"highlight! NonText guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"
highlight! link EndOfBuffer NonText
highlight! PreInsert guifg=#585858 guibg=NONE ctermfg=240 ctermbg=NONE gui=NONE cterm=NONE term=NONE

# tabs
highlight! TabLine guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
execute $"highlight! TabLineSel guifg={colors.normal.guifg} guibg=#d7ffff ctermfg={colors.normal.ctermfg} ctermbg=195 gui=NONE cterm=NONE term=NONE"
highlight! TabLineFill guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE

execute $"highlight! Folded guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! FoldColumn guifg={colors.normal.guifg} guibg=#d7ffff ctermfg={colors.normal.ctermfg} ctermbg=195 gui=NONE cterm=NONE term=NONE"
execute $"highlight! SyntaxFoldLevel guifg={colors.normal.guifg} guibg=#d7ffff ctermfg={colors.normal.ctermfg} ctermbg=195 gui=NONE cterm=NONE term=NONE"

execute $"highlight! Directory guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! Question guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! MoreMsg guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! Title guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# complete popup menu
highlight! Pmenu guifg=NONE guibg=#ffffaf ctermfg=NONE ctermbg=229 gui=NONE cterm=NONE term=NONE
highlight! PmenuSel guifg=NONE guibg=#dfffd7 ctermfg=NONE ctermbg=194 gui=NONE cterm=NONE term=NONE
highlight! PmenuMatch guifg=#d70000 guibg=NONE ctermfg=160 ctermbg=NONE gui=NONE cterm=NONE term=NONE
highlight! PmenuMatchSel guifg=#d70000 guibg=#dfffd7 ctermfg=160 ctermbg=194 gui=NONE cterm=NONE term=NONE
highlight! PmenuKind guifg=#005f00 guibg=#ffffaf ctermfg=22 ctermbg=229 gui=NONE cterm=NONE term=NONE
highlight! PmenuKindSel guifg=#005f00 guibg=#dfffd7 ctermfg=22 ctermbg=194 gui=NONE cterm=NONE term=NONE
highlight! PmenuSbar guifg=NONE guibg=#afaf87 ctermfg=NONE ctermbg=144 gui=NONE cterm=NONE term=NONE
highlight! PmenuThumb guifg=NONE guibg=#afafff ctermfg=NONE ctermbg=147 gui=NONE cterm=NONE term=NONE
highlight! PmenuExtra guifg=#585858 guibg=#ffffaf ctermfg=240 ctermbg=229 gui=NONE cterm=NONE term=NONE
highlight! PmenuExtraSel guifg=#585858 guibg=#dfffd7 ctermfg=240 ctermbg=194 gui=NONE cterm=NONE term=NONE
highlight! link PopupSelected PmenuSel

# :help ins-completion
highlight! clear ComplMatchIns

# :help  'cmdheight'
highlight! clear MesgArea

# :help completepopup
execute $"highlight! InfoPopup guifg={colors.normal.guifg} guibg=#d7ffaf ctermfg={colors.normal.ctermfg} ctermbg=193 gui=NONE cterm=NONE term=NONE"

# :terminal
highlight! link Terminal Normal
highlight! StatusLineTerm guifg=white guibg=#005f00 ctermfg=white ctermbg=22 gui=NONE cterm=NONE term=NONE
highlight! link StatusLineTermNC StatusLineNC

# :help syntax
highlight! link Boolean Normal
highlight! link Character Normal
highlight! Comment guifg=#585858 guibg=NONE ctermfg=240 ctermbg=NONE gui=NONE cterm=NONE term=NONE
highlight! link Conditional Normal
highlight! link Constant Normal
highlight! link Debug Normal
highlight! link Define Normal
highlight! link Delimiter Normal
highlight! link Error Normal
highlight! link Exception Normal
highlight! link Float Normal
highlight! link Function Normal
highlight! link Identifier Normal
highlight! clear Ignore
highlight! link Include Normal
highlight! link Keyword Normal
highlight! link Label Normal
highlight! link Macro Normal
highlight! link Number Normal
highlight! link Operator Normal
highlight! link PreCondit Normal
highlight! link PreProc Normal
highlight! link Repeat Normal
highlight! link Special Normal
highlight! link SpecialChar Normal
highlight! link SpecialComment Normal
highlight! link Statement Normal
highlight! link StorageClass Normal
highlight! link String Normal
highlight! link Structure Normal
highlight! link Tag Normal
highlight! link Todo Normal
highlight! link Type Normal
highlight! link Typedef Normal
highlight! link Underlined Normal

# signs column
# highlight! SignColumn guifg={colors.normal.guifg} guibg=#afaf87 ctermfg={colors.normal.ctermfg} ctermbg=144 gui=NONE cterm=NONE term=NONE
highlight! link SignColumn Normal

# TODO
# debugPC
# debugBreakpoint

# syntax errors/warnings
highlight! ErrorMsg guifg=white guibg=#ff0000 ctermfg=white ctermbg=1 gui=NONE cterm=NONE term=NONE
execute $"highlight! WarningMsg guifg={colors.normal.guifg} guibg=#ffff00 ctermfg={colors.normal.ctermfg} ctermbg=11 gui=NONE cterm=NONE term=NONE"
highlight! SyntaxErrorClear guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
execute $"highlight! SyntaxError guifg={colors.normal.guifg} guibg=#ff0000 ctermfg={colors.normal.ctermfg} ctermbg=9 gui=NONE cterm=NONE term=NONE"
execute $"highlight! SyntaxWarning guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! SyntaxErrorPlus guifg=#800000 guibg=#ffffff ctermfg=1 ctermbg=15 gui=NONE cterm=NONE term=NONE

# checker sh
highlight! link SyntaxGoodSH Normal
highlight! SyntaxErrorSH guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE

highlight! link SyntaxGoodSHELLCHECK Normal
highlight! SyntaxErrorSHELLCHECK guifg=#cc7832 guibg=NONE ctermfg=172 ctermbg=NONE gui=NONE cterm=NONE term=NONE

# checker python
highlight! link SyntaxGoodPY Normal
highlight! SyntaxErrorPYTHON guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE

highlight! link SyntaxGoodPEP8 Normal
highlight! SyntaxErrorPEP8 guifg=#cc7832 guibg=NONE ctermfg=172 ctermbg=NONE gui=NONE cterm=NONE term=NONE

# checker go
highlight! link SyntaxGoodGO Normal
highlight! SyntaxErrorGO guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE

highlight! link SyntaxGoodGOVET Normal
highlight! SyntaxErrorGOVET guifg=#cc7832 guibg=NONE ctermfg=172 ctermbg=NONE gui=NONE cterm=NONE term=NONE
