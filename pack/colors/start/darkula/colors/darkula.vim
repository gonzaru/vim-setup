vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# My darkula theme :)

# do not read the file if it is already loaded
if get(g:, 'loaded_darkula') && get(g:, 'colors_name', '') == "darkula"
  finish
endif
g:loaded_darkula = true

# number of colors
if !has('gui_running') && str2nr(&t_Co) < 256
  finish
endif

# dark background
set background=dark

# clean up
highlight clear

if exists("syntax_on")
  syntax reset
endif

# colorScheme
g:colors_name = "darkula"

# global variables
if !exists('g:darkula_style')
  g:darkula_style = "light"  # light, dark
endif
if !exists('g:darkula_cursor2')
  g:darkula_cursor2 = false  # true, false
endif
if !exists('g:darkula_cursor2')
  g:darkula_cursor2 = false  # true, false
endif
if !exists('g:darkula_pmenumatch2')
  g:darkula_pmenumatch2 = false  # true, false
endif

# colors
const isdark = g:darkula_style == "dark" ? true : false
const cursor2 = g:darkula_cursor2
const pmenumatch2 = g:darkula_pmenumatch2
const colors = {
  'normal': {
    'guifg': '#bbbbbb',
    'guibg': isdark ? '#1c1c1c' : '#2b2b2b',
    'ctermfg': 145,
    'ctermbg': isdark ? 234 : 235
  }
}

execute $"highlight! Normal guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! MatchParen guifg=#ffef32 guibg={colors.normal.guibg} ctermfg=226 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

highlight! Visual guifg=NONE guibg=#214283 ctermfg=NONE ctermbg=25 gui=NONE cterm=NONE term=NONE
# TODO
# VisualNOS

# see PmenuSel
execute $"highlight! WildMenu guifg={colors.normal.guifg} guibg=#113a5c ctermfg={colors.normal.ctermfg} ctermbg=25 gui=NONE cterm=NONE term=NONE"

# split windows
execute $"highlight! StatusLine guifg={colors.normal.guifg} guibg={isdark ? '#444444' : '#4e4e4e'} ctermfg={colors.normal.ctermfg} ctermbg={isdark ? 238 : 239} gui=NONE cterm=NONE term=NONE"
execute $"highlight! StatusLineNC guifg=#808080 guibg={isdark ? '#303030' : '#3a3a3a'} ctermfg=244 ctermbg={isdark ? 236 : 237} gui=NONE cterm=NONE term=NONE"

# vertical split
execute $"highlight! VertSplit guifg={colors.normal.guifg} guibg={isdark ? '#303030' : '#3a3a3a'} ctermfg={colors.normal.ctermfg} ctermbg={isdark ? 236 : 237} gui=NONE cterm=NONE term=NONE"

execute $"highlight! Cursor guifg={cursor2 ? "white" : "black"} guibg={cursor2 ? "#606060" : colors.normal.guifg} gui=NONE cterm=NONE term=NONE"
# language keymap cursor (i_CTRL-^)
highlight! link lCursor Cursor
execute $"highlight! CursorLine guifg=NONE guibg={isdark ? '#262626' : '#333333'} ctermfg=NONE ctermbg={isdark ? 235 : 236} gui=NONE cterm=NONE term=NONE"
highlight! CursorLineNR guifg=#999999 guibg=NONE ctermfg=102 ctermbg=NONE gui=NONE cterm=NONE term=NONE
highlight! link CursorColumn CursorLine

# current quickfix item
highlight! link QuickFixLine PmenuSel

# TODO
# ToolbarLine
# ToolbarButton

# TODO
execute $"highlight! ColorColumn guifg={colors.normal.guifg} guibg={isdark ? '#3a3a3a' : '#4a4a4a'} ctermfg={colors.normal.ctermfg} ctermbg={isdark ? 237 : 238} gui=NONE cterm=NONE term=NONE"

# spell/diagnostics: SpellBad = error, SpellRare = warning
execute $"highlight! SpellBad guifg=#bc3f3c guibg={colors.normal.guibg} ctermfg=124 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! SpellRare guifg=pink guibg={colors.normal.guibg} ctermfg=175 ctermbg={colors.normal.ctermbg} gui=underline cterm=underline term=NONE"
execute $"highlight! SpellCap guifg=#d7ffff guibg={colors.normal.guibg} ctermfg=195 ctermbg={colors.normal.ctermbg} gui=underline cterm=underline term=NONE"
highlight! link SpellLocal SpellRare

highlight! Search guifg=NONE guibg=#31583c ctermfg=NONE ctermbg=22 gui=NONE cterm=NONE term=NONE
highlight! link CurSearch Search
highlight! link IncSearch Search

highlight! LineNr guifg=#606366 guibg=NONE ctermfg=59 ctermbg=NONE gui=NONE cterm=NONE term=NONE
highlight! link LineNrAbove LineNr
highlight! link LineNrBelow LineNr

# TODO
# execute $"highlight! SpecialKey guifg=pink guibg={COLORS['normal']['guibg'} ctermfg=175 ctermbg={COLORS['normal']['ctermbg'} gui=NONE cterm=NONE term=NONE"
highlight! SpecialKey guifg=pink guibg=NONE ctermfg=175 ctermbg=NONE gui=NONE cterm=NONE term=NONE

# TODO
# diff (diffthis)
execute $"highlight! DiffText guifg=#afafff guibg={colors.normal.guibg} ctermfg=147 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! DiffChange guifg=#d7ffff guibg={colors.normal.guibg} ctermfg=195 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! DiffDelete guifg=#ff8787 guibg={colors.normal.guibg} ctermfg=210 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! DiffAdd guifg=#afffaf guibg={colors.normal.guibg} ctermfg=157 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# git
highlight! link diffAdded DiffAdd
highlight! link diffChanged DiffChange
highlight! link diffFile Normal
highlight! link diffIndexLine Normal
highlight! link diffLine DiffChange
highlight! link diffNewFile Normal
highlight! link diffOldFile Normal
highlight! link diffRemoved DiffDelete
highlight! link diffSubname Normal

# TODO
execute $"highlight! Conceal guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"

# TODO ~ (new buffer)
execute $"highlight! NonText guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"
highlight! link EndOfBuffer NonText
highlight! PreInsert guifg=#808080 guibg=NONE ctermfg=244 ctermbg=NONE gui=NONE cterm=NONE term=NONE

# tabs
execute $"highlight! TabLine guifg=#808080 guibg={isdark ? '#3a3a3a' : '#444444'} ctermfg=244 ctermbg={isdark ? 237 : 238} gui=NONE cterm=NONE term=NONE"
execute $"highlight! TabLineSel guifg={colors.normal.guifg} guibg={isdark ? '#444444' : '#4e4e4e'} ctermfg={colors.normal.ctermfg} ctermbg={isdark ? 238 : 239} gui=NONE cterm=NONE term=NONE"
execute $"highlight! TabLineFill guifg={colors.normal.guifg} guibg={isdark ? '#3a3a3a' : '#444444'} ctermfg={colors.normal.ctermfg} ctermbg={isdark ? 237 : 238} gui=NONE cterm=NONE term=NONE"

# TODO
execute $"highlight! Folded guifg=#999999 guibg={colors.normal.guibg} ctermfg=102 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! FoldColumn guifg=#999999 guibg={colors.normal.guibg} ctermfg=102 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
# highlight! SyntaxFoldLevel guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE

execute $"highlight! Directory guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! Question guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! MoreMsg guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

execute $"highlight! Title guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# complete popup menu
execute $"highlight! Pmenu guifg=NONE guibg={isdark ? '#3a3a3a' : '#46484a'} ctermfg=NONE ctermbg={isdark ? 237 : 238} gui=NONE cterm=NONE term=NONE"
highlight! PmenuSel guifg=NONE guibg=#113a5c ctermfg=NONE ctermbg=25 gui=NONE cterm=NONE term=NONE
execute $"highlight! PmenuMatch guifg={pmenumatch2 ? '#ffaf5f' : '#eeeeee'} guibg={isdark ? '#3a3a3a' : '#46484a'} ctermfg={pmenumatch2 ? 215 : 255} ctermbg={isdark ? 237 : 238} gui=NONE cterm=NONE term=NONE"
execute $"highlight! PmenuMatchSel guifg={pmenumatch2 ? '#ffaf5f' : '#eeeeee'} guibg=#113a5c ctermfg={pmenumatch2 ? 215 : 255} ctermbg=25 gui=NONE cterm=NONE term=NONE"
execute $"highlight! PmenuKind guifg=#cc7832 guibg={isdark ? '#3a3a3a' : '#46484a'} ctermfg=172 ctermbg={isdark ? 237 : 238} gui=NONE cterm=NONE term=NONE"
highlight! PmenuKindSel guifg=#cc7832 guibg=#113a5c ctermfg=172 ctermbg=25 gui=NONE cterm=NONE term=NONE
execute $"highlight! PmenuSbar guifg=NONE guibg={colors.normal.guibg} ctermfg=NONE ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! PmenuThumb guifg=NONE guibg={isdark ? '#303030' : '#999999'} ctermfg=NONE ctermbg={isdark ? 236 : 102} gui=NONE cterm=NONE term=NONE"
execute $"highlight! PmenuExtra guifg=#808080 guibg={isdark ? '#3a3a3a' : '#46484a'} ctermfg=244 ctermbg={isdark ? 237 : 238} gui=NONE cterm=NONE term=NONE"
highlight! PmenuExtraSel guifg=#949494 guibg=#113a5c ctermfg=246 ctermbg=25 gui=NONE cterm=NONE term=NONE
highlight! link PopupSelected PmenuSel

# :help ins-completion
highlight! clear ComplMatchIns

# :help  'cmdheight'
highlight! clear MesgArea

# :help completepopup
execute $"highlight! InfoPopup guifg={colors.normal.guifg} guibg={isdark ? '#262626' : '#333333'} ctermfg={colors.normal.ctermfg} ctermbg={isdark ? 235 : 236} gui=NONE cterm=NONE term=NONE"

# :terminal
highlight! link Terminal Normal
highlight! link StatusLineTerm StatusLine
highlight! link StatusLineTermNC StatusLineNC

# :help syntax
execute $"highlight! Boolean guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Character guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Comment guifg=#999999 guibg={colors.normal.guibg} ctermfg=102 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Conditional guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Constant guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Debug guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Define guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Delimiter guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! Error guifg=white guibg=#ff0000 ctermfg=white ctermbg=196 gui=NONE cterm=NONE term=NONE
execute $"highlight! Exception guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Float guifg=#6897bb guibg={colors.normal.guibg} ctermfg=67 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Function guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Identifier guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
# execute $"highlight! Ignore guifg=black guibg={colors.normal.guibg} ctermfg=black ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! clear Ignore
execute $"highlight! Include guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Keyword guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Label guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Macro guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Number guifg=#6897bb guibg={colors.normal.guibg} ctermfg=67 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Operator guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! PreCondit guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! PreProc guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Repeat guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Special guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! SpecialChar guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! SpecialComment guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Statement guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! StorageClass guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! String guifg=#6a8759 guibg={colors.normal.guibg} ctermfg=65 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Structure guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Tag guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Todo guifg=#a8c023 guibg={colors.normal.guibg} ctermfg=142 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Type guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Typedef guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! Underlined guifg={colors.normal.guifg} guibg={colors.normal.guibg} ctermfg={colors.normal.ctermfg} ctermbg={colors.normal.ctermbg} gui=underline cterm=NONE term=NONE"

# signs column
# highlight! SignColumn guifg=#303030 guibg=#262626 ctermfg=236 ctermbg=235 gui=NONE cterm=NONE term=NONE
highlight! link SignColumn Normal

# TODO
# debugPC
# debugBreakpoint

# syntax errors/warnings
highlight! ErrorMsg guifg=white guibg=#ff0000 ctermfg=white ctermbg=1 gui=NONE cterm=NONE term=NONE
highlight! WarningMsg guifg=black guibg=#ffff00 ctermfg=black ctermbg=11 gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorClear guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxError guifg=black guibg=#ff0000 ctermfg=black ctermbg=9 gui=NONE cterm=NONE term=NONE
execute $"highlight! SyntaxWarning guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"
highlight! SyntaxErrorPlus guifg=#800000 guibg=#ffffff ctermfg=1 ctermbg=15 gui=NONE cterm=NONE term=NONE

# checker sh
highlight! link SyntaxGoodSH Normal
highlight! SyntaxErrorSH guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE
highlight! link SyntaxGoodSHELLCHECK Normal
execute $"highlight! SyntaxErrorSHELLCHECK guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"

# checker python
highlight! link SyntaxGoodPY Normal
highlight! SyntaxErrorPYTHON guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE
highlight! link SyntaxGoodPEP8 Normal
execute $"highlight! SyntaxErrorPEP8 guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"

# checker go
highlight! link SyntaxGoodGO Normal
highlight! SyntaxErrorGO guifg=#ff0000 guibg=NONE ctermfg=196 ctermbg=NONE gui=NONE cterm=NONE term=NONE
highlight! link SyntaxGoodGOVET Normal
execute $"highlight! SyntaxErrorGOVET guifg={colors.normal.guifg} guibg=NONE ctermfg={colors.normal.ctermfg} ctermbg=NONE gui=NONE cterm=NONE term=NONE"

# go syntax
# go#config#HighlightFunctions()
execute $"highlight! goFunction guifg=#ffd75f guibg={colors.normal.guibg} ctermfg=221 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! goReceiverVar guifg=#4eade5 guibg={colors.normal.guibg} ctermfg=74 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! goReceiverType guifg=#6fafbd guibg={colors.normal.guibg} ctermfg=73 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! link goPointerOperator Normal

# go#config#HighlightFunctionParameters()
highlight! link goParamName Normal

# go#config#HighlightFunctionCalls()
# TODO ctermfg=137
execute $"highlight! goFunctionCall guifg=#d7af5f guibg={colors.normal.guibg} ctermfg=179 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# go#config#HighlightTypes()
execute $"highlight! goTypeConstructor guifg=#6fafbd guibg={colors.normal.guibg} ctermfg=73 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
execute $"highlight! goTypeDecl guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! link goTypeName Normal
execute $"highlight! goDeclType guifg=#cc7832 guibg={colors.normal.guibg} ctermfg=172 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# go#config#HighlightFields()
execute $"highlight! goField guifg=#6fafbd guibg={colors.normal.guibg} ctermfg=73 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# go#config#HighlightBuildConstraints()
execute $"highlight! goBuildKeyword guifg=#629755 guibg={colors.normal.guibg} ctermfg=64 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! link goBuildDirectives Normal

# go#config#HighlightGenerateTags()
execute $"highlight! goGenerate guifg=#629755 guibg={colors.normal.guibg} ctermfg=64 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
# TODO
# goGenerateVariables points to Special

# custom
# see ~/.vim/after/syntax/go.vim
execute $"highlight! goCustomFunctionName1 guifg=#afbf7e guibg={colors.normal.guibg} ctermfg=144 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# vim syntax
execute $"highlight! vimEnvVar guifg=#b09d79 guibg={colors.normal.guibg} ctermfg=137 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"
highlight! link vimFunction Normal
highlight! link vimFuncVar Normal
highlight! link vimOption Normal
highlight! link vimUserFunc Normal
highlight! link vimVar Normal
highlight! link vimFBVar Normal
highlight! link vimHLGroup Normal
highlight! link vimEchoHLNone Normal
execute $"highlight! vimFuncName guifg=#afbf7e guibg={colors.normal.guibg} ctermfg=144 ctermbg={colors.normal.ctermbg} gui=NONE cterm=NONE term=NONE"

# sh syntax
highlight! link shVariable Normal
highlight! link shOption Normal
highlight! link shFunction Normal
highlight! link shShellVariables Normal
highlight! link shQuote String
# TODO match function color for function name() <--
# TODO match parenthesis colors if (( )) <--
