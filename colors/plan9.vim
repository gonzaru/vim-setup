vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# My plan9 theme :)

# colors
# 230 (yellow plan9)
# 195 (cyan)
# 147 (purple)
# 144 (green/brown numbers)
# 187 (gray/brown clear)
# 230 looks same as lightyellow
# 160 looks a red color
# 210 looks a red light color

# do not read the file if it is already loaded
if get(g:, 'loaded_plan9') && get(g:, 'colors_name', '') == "plan9"
  finish
endif
g:loaded_plan9 = true

# number of colors
if !has('gui_running') && str2nr(&t_Co) != 256
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
  g:plan9_style = "light"  # light, dark
endif

# colors
const isdark = g:plan9_style == "dark" ? true : false
const colors = {
  'normal': {
    'guifg': 'black',
    'guibg': isdark ? '#ffffaf' : '#ffffd7',
    'ctermfg': 'black',
    'ctermbg': isdark ? 229 : 230
  }
}

execute $"highlight! Normal guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

highlight! MatchParen guifg=black guibg=#afaf87 ctermfg=black ctermbg=144 gui=NONE cterm=NONE term=NONE

execute $"highlight! Visual guifg=black guibg={isdark ? '#ffff87' : '#ffffaf'} ctermfg=black ctermbg={isdark ? 228 : 229} gui=NONE cterm=NONE term=NONE"

# TODO
# VisualNOS

execute $"highlight! WildMenu guifg=black guibg={isdark ? '#ffff87' : '#ffffaf'} ctermfg=black ctermbg={isdark ? 228 : 229} gui=NONE cterm=NONE term=NONE"

# split windows
highlight! StatusLine guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
execute $"highlight! StatusLineNC guifg=white guibg={isdark ? '#303030' : '#3a3a3a'} ctermfg=white ctermbg={isdark ? 236 : 237} gui=NONE cterm=NONE term=NONE"

# vertical split color
highlight! VertSplit guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE


# execute $"highlight! Cursor guifg=white guibg={colors.normal.guifg} gui=NONE cterm=NONE term=NONE"
# execute $"highlight! Cursor guifg=white guibg={isdark ? '#606060' : '#8888cc'} gui=NONE cterm=NONE term=NONE"
highlight! Cursor guifg=white guibg=#606060 gui=NONE cterm=NONE term=NONE
# highlight! Cursor guifg=white guibg=#8888cc gui=NONE cterm=NONE term=NONE
# language keymap cursor (i_CTRL-^)
highlight! link lCursor Cursor
execute $"highlight! CursorLine guifg=NONE guibg={isdark ? '#d7d787' : '#d7d7af'} ctermfg=NONE ctermbg={isdark ? 186 : 187} gui=NONE cterm=NONE term=NONE"
execute $"highlight! CursorLineNR guifg=#d70000 guibg={isdark ? '#d7d787' : '#d7d7af'} ctermfg=160 ctermbg={isdark ? 186 : 187} gui=NONE cterm=NONE term=NONE"
highlight! link CursorColumn CursorLine

# current quickfix item
highlight! link QuickFixLine PmenuSel

# TODO
# ToolbarLine
# ToolbarButton

execute $"highlight! ColorColumn guifg=black guibg={isdark ? '#ffd700' : '#ffd75f'} ctermfg=black ctermbg={isdark ? 220 : 221} gui=NONE cterm=NONE term=NONE"

# spell/diagnostics: SpellBad = error, SpellRare = warning
highlight! SpellBad guifg=black guibg=#ff8787 ctermfg=black ctermbg=210 gui=NONE cterm=NONE term=NONE
highlight! SpellRare guifg=pink guibg=#ff8787 ctermfg=black ctermbg=210 gui=underline cterm=underline term=NONE
highlight! SpellCap guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=underline cterm=underline term=NONE
highlight! link SpellLocal SpellRare

execute $"highlight! Search guifg=black guibg={isdark ? '#ffff87' : '#ffffaf'} ctermfg=black ctermbg={isdark ? 228 : 229} gui=NONE cterm=NONE term=NONE"
highlight! link CurSearch Search
highlight! link IncSearch Search

execute $"highlight! LineNr guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! link LineNrAbove LineNr
highlight! link LineNrBelow LineNr

execute $"highlight! SpecialKey guifg=#d70000 guibg={isdark ? '#d7d787' : '#d7d7af'} ctermfg=160 ctermbg={isdark ? 186 : 187} gui=NONE cterm=NONE term=NONE"

# diff (diffthis)
highlight! DiffText guifg=black guibg=#afafff ctermfg=black ctermbg=147 gui=NONE cterm=NONE term=NONE
highlight! DiffChange guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE
highlight! DiffDelete guifg=black guibg=#ff8787 ctermfg=black ctermbg=210 gui=NONE cterm=NONE term=NONE
highlight! DiffAdd guifg=black guibg=#afffaf ctermfg=black ctermbg=157 gui=NONE cterm=NONE term=NONE

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

highlight! Conceal guifg=black guibg=#ffff00 ctermfg=black ctermbg=226 gui=NONE cterm=NONE term=NONE

execute $"highlight! NonText guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! link EndOfBuffer NonText

# tabs
highlight! TabLine guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! TabLineSel guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE
highlight! TabLineFill guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE

execute $"highlight! Folded guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! FoldColumn guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE
highlight! SyntaxFoldLevel guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE

execute $"highlight! Directory guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! Question guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! MoreMsg guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! Title guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# complete popup menu
highlight! Pmenu guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
execute $"highlight! PmenuSel guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! PmenuMatch guifg={isdark ? '#ffff87' : '#ffffaf'} guibg=black ctermfg={isdark ? 228 : 229} ctermbg=black gui=NONE cterm=NONE term=NONE"
execute $"highlight! PmenuMatchSel guifg=#d70000 guibg={isdark ? '#ffff87' : '#ffffaf'} ctermfg=160 ctermbg={isdark ? 228 : 229} gui=NONE cterm=NONE term=NONE"
highlight! link PmenuKind Pmenu
highlight! link PmenuKindSel PmenuSel
execute $"highlight! PmenuSbar guifg=NONE guibg={colors.normal.guibg} ctermfg=NONE ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! PmenuThumb guifg=NONE guibg=#afafff ctermfg=NONE ctermbg=147 gui=NONE cterm=NONE term=NONE
# TODO
# PmenuExtra
# PmenuExtraSel

# :help completepopup
highlight! InfoPopup guifg=black guibg=lightgray ctermfg=black ctermbg=lightgray gui=NONE cterm=NONE term=NONE

# :terminal
highlight! link Terminal Normal
highlight! StatusLineTerm guifg=white guibg=#005f00 ctermfg=white ctermbg=22 gui=NONE cterm=NONE term=NONE
highlight! link StatusLineTermNC StatusLineNC

# :help syntax
highlight! link Boolean Normal
highlight! link Character Normal
highlight! link Comment Normal
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
highlight! link Ignore Normal
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
# highlight! SignColumn guifg=black guibg=#afaf87 ctermfg=black ctermbg=144 gui=NONE cterm=NONE term=NONE
highlight! link SignColumn Normal

# TODO
# debugPC
# debugBreakpoint

# syntax errors/warnings
highlight! ErrorMsg guifg=white guibg=#ff0000 ctermfg=white ctermbg=1 gui=NONE cterm=NONE term=NONE
highlight! WarningMsg guifg=black guibg=#ffff00 ctermfg=black ctermbg=11 gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorClear guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxError guifg=black guibg=#ff0000 ctermfg=black ctermbg=9 gui=NONE cterm=NONE term=NONE
execute $"highlight! SyntaxWarning guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
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
