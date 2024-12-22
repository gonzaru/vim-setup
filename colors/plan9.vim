vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# My plan9 theme :)

# colors
# 228 (yellow plan9)
# 195 (cyan)
# 147 (purple)
# 144 (green/brown numbers)
# 187 (gray/brown clear)
# 230 looks same as lightyellow
# 160 looks a red color
# 210 looks a red light color

# do not read the file if it is already loaded
if get(g:, 'loaded_plan9') && get(g:, 'colors_name') == "plan9"
  finish
endif
g:loaded_plan9 = true

# light background
if &background != "light"
  set background=light
endif

# clean up
highlight clear

if exists("syntax_on")
  syntax reset
endif

# colorscheme
g:colors_name = "plan9"

highlight! Normal guifg=black guibg=#ffff87 ctermfg=black ctermbg=228 gui=NONE cterm=NONE term=NONE

highlight! MatchParen guifg=black guibg=#afaf87 ctermfg=black ctermbg=144 gui=NONE cterm=NONE term=NONE

highlight! Visual guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE
# TODO
# VisualNOS

highlight! WildMenu guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE

# split windows
highlight! StatusLine guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! StatusLineNC guifg=white guibg=#333333 ctermfg=white ctermbg=236 gui=NONE cterm=NONE term=NONE

# vertical split color
highlight! VertSplit guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE

highlight! Cursor guifg=white guibg=#606060 gui=NONE cterm=NONE term=NONE
# language keymap cursor (i_CTRL-^)
highlight! link lCursor Cursor
highlight! CursorLine guifg=NONE guibg=#d7d787 ctermfg=NONE ctermbg=186 gui=NONE cterm=NONE term=NONE
highlight! CursorLineNR guifg=#d70000 guibg=#ffff87 ctermfg=160 ctermbg=228 gui=NONE cterm=NONE term=NONE
highlight! link CursorColumn CursorLine

# current quickfix item
highlight! link QuickFixLine PmenuSel

# TODO
# ToolbarLine
# ToolbarButton

highlight! ColorColumn guifg=black guibg=#ffd75f ctermfg=black ctermbg=221 gui=NONE cterm=NONE term=NONE

# spell/diagnostics: SpellBad = error, SpellRare = warning
highlight! SpellBad guifg=black guibg=#ff8787 ctermfg=black ctermbg=210 gui=NONE cterm=NONE term=NONE
highlight! SpellRare guifg=pink guibg=#ff8787 ctermfg=black ctermbg=210 gui=underline cterm=underline term=NONE
highlight! SpellCap guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=underline cterm=underline term=NONE
highlight! link SpellLocal SpellRare

highlight! Search guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE
highlight! link CurSearch Search
highlight! link IncSearch Search

highlight! LineNr guifg=black guibg=#ffff87 ctermfg=black ctermbg=228 gui=NONE cterm=NONE term=NONE
highlight! link LineNrAbove LineNr
highlight! link LineNrBelow LineNr

highlight! SpecialKey guifg=#d70000 guibg=#d7d7af ctermfg=160 ctermbg=187 gui=NONE cterm=NONE term=NONE

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

highlight! NonText guifg=black guibg=#ffff87 ctermfg=black ctermbg=228 gui=NONE cterm=NONE term=NONE
highlight! link EndOfBuffer NonText

# tabs
highlight! TabLine guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! TabLineSel guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE
highlight! TabLineFill guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE

highlight! Folded guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE
highlight! FoldColumn guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE
highlight! SyntaxFoldLevel guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE

highlight! Directory guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE

highlight! Question guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE

highlight! MoreMsg guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE

highlight! Title guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE

# complete popup menu
highlight! Pmenu guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! PmenuSel guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE
highlight! PmenuMatch guifg=#ffff5f guibg=black ctermfg=227 ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! PmenuMatchSel guifg=#d70000 guibg=#ffff5f ctermfg=160 ctermbg=227 gui=NONE cterm=NONE term=NONE
highlight! link PmenuKind Pmenu
highlight! link PmenuKindSel PmenuSel
highlight! PmenuSbar guifg=NONE guibg=#ffff87 ctermfg=NONE ctermbg=228 gui=NONE cterm=NONE term=NONE
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
highlight! SignColumn guifg=black guibg=#afaf87 ctermfg=black ctermbg=144 gui=NONE cterm=NONE term=NONE

# TODO
# debugPC
# debugBreakpoint

# syntax errors/warnings
highlight! ErrorMsg guifg=white guibg=#ff0000 ctermfg=white ctermbg=1 gui=NONE cterm=NONE term=NONE
highlight! WarningMsg guifg=black guibg=#ffff00 ctermfg=black ctermbg=11 gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorClear guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxError guifg=black guibg=#ff0000 ctermfg=black ctermbg=9 gui=NONE cterm=NONE term=NONE
highlight! SyntaxWarning guifg=black guibg=#ffff5f ctermfg=black ctermbg=227 gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorPlus guifg=#800000 guibg=#ffffff ctermfg=1 ctermbg=15 gui=NONE cterm=NONE term=NONE

# checker sh
highlight! link SyntaxGoodSH Normal
if &signcolumn == "number"
  highlight! SyntaxErrorSH guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE
else
  highlight! SyntaxErrorSH guifg=white guibg=#ff0000 ctermfg=white ctermbg=196 gui=NONE cterm=NONE term=NONE
endif

highlight! link SyntaxGoodSHELLCHECK Normal
if &signcolumn == "number"
  highlight! SyntaxErrorSHELLCHECK guifg=#cc7832 guibg=NONE ctermfg=172 ctermbg=NONE gui=NONE cterm=NONE term=NONE
else
  highlight! SyntaxErrorSHELLCHECK guifg=#cc7832 guibg=#d7d7af ctermfg=172 ctermbg=187 gui=NONE cterm=NONE term=NONE
endif

# checker python
highlight! link SyntaxGoodPY Normal
if &signcolumn == "number"
  highlight! SyntaxErrorPYTHON guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE
else
  highlight! SyntaxErrorPYTHON guifg=white guibg=#ff0000 ctermfg=white ctermbg=196 gui=NONE cterm=NONE term=NONE
endif

highlight! link SyntaxGoodPEP8 Normal
if &signcolumn == "number"
  highlight! SyntaxErrorPEP8 guifg=#cc7832 guibg=NONE ctermfg=172 ctermbg=NONE gui=NONE cterm=NONE term=NONE
else
  highlight! SyntaxErrorPEP8 guifg=#cc7832 guibg=#d7d7af ctermfg=172 ctermbg=187 gui=NONE cterm=NONE term=NONE
endif

# checker go
highlight! link SyntaxGoodGO Normal
if &signcolumn == "number"
  highlight! SyntaxErrorGO guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE
else
  highlight! SyntaxErrorGO guifg=white guibg=#ff0000 ctermfg=white ctermbg=196 gui=NONE cterm=NONE term=NONE
endif

highlight! link SyntaxGoodGOVET Normal
if &signcolumn == "number"
  highlight! SyntaxErrorGOVET guifg=#cc7832 guibg=NONE ctermfg=172 ctermbg=NONE gui=NONE cterm=NONE term=NONE
else
  highlight! SyntaxErrorGOVET guifg=#cc7832 guibg=#d7d7af ctermfg=172 ctermbg=187 gui=NONE cterm=NONE term=NONE
endif
