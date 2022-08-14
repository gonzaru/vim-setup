vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# My darkula theme :)

# do not read the file if it is already loaded
if get(g:, 'loaded_darkula') == 1 && get(g:, 'colors_name') == "darkula"
   finish
 endif
g:loaded_darkula = 1

# dark background
if &background != "dark"
  set background=dark
endif

# clean up
highlight clear

if exists("syntax_on")
  syntax reset
endif

# colorScheme
g:colors_name = "darkula"

# colors
const COLORS = {
  'normal': {
    'guifg': '#bbbbbb',
    'guibg': '#2b2b2b',
    'ctermfg': 145,
    'ctermbg': 235
  }
}

execute "highlight! Normal guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

execute "highlight! MatchParen guifg=#ffef32 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=226 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

highlight! Visual guifg=NONE guibg=#214283 ctermfg=NONE ctermbg=25 gui=NONE cterm=NONE term=NONE

highlight! WildMenu guifg=#113a5c guibg=#bbbbbb ctermfg=25 ctermbg=145 gui=NONE cterm=NONE term=NONE

# split windows
execute "highlight! StatusLine guifg=" .. COLORS['normal']['guifg'] .. " guibg=#333333 ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=236 gui=NONE cterm=NONE term=NONE"
execute "highlight! StatusLineNC guifg=" .. COLORS['normal']['guifg'] .. " guibg=#4A4A4A ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=238 gui=NONE cterm=NONE term=NONE"

# vertical split
execute "highlight! VertSplit guifg=" .. COLORS['normal']['guifg'] .. " guibg=#333333 ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=236 gui=NONE cterm=NONE term=NONE"

highlight! Cursor guifg=black guibg=#bbbbbb gui=NONE cterm=NONE term=NONE
highlight! CursorLine guifg=NONE guibg=#333333 ctermfg=NONE ctermbg=236 gui=NONE cterm=NONE term=NONE
highlight! CursorLineNR guifg=#999999 guibg=#333333 ctermfg=102 ctermbg=236 gui=bold cterm=bold term=NONE
highlight! link CursorColumn CursorLine

# TODO
execute "highlight! ColorColumn guifg=" .. COLORS['normal']['guifg'] .. " guibg=#4A4A4A ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=238 gui=NONE cterm=NONE term=NONE"

# spell/diagnostics: SpellBad = error, SpellRare = warning
execute "highlight! SpellBad guifg=#bc3f3c guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=124 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! SpellRare guifg=pink guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=175 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=underline cterm=underline term=NONE"
execute "highlight! SpellCap guifg=#d7ffff guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=195 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=underline cterm=underline term=NONE"

highlight! Search guifg=NONE guibg=#31583c ctermfg=NONE ctermbg=22 gui=NONE cterm=NONE term=NONE

execute "highlight! LineNr guifg=#606366 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=59 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# TODO
# execute "highlight! SpecialKey guifg=pink guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=175 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! SpecialKey guifg=pink guibg=black ctermfg=175 ctermbg=black gui=NONE cterm=NONE term=NONE"

# TODO
# diff (diffthis)
execute "highlight! DiffText guifg=#afafff guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=147 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! DiffChange guifg=#d7ffff guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=195 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! DiffDelete guifg=#ff8787 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=210 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! DiffAdd guifg=#afffaf guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=157 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# TODO
execute "highlight! Conceal guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# TODO ~ (new buffer)
# execute "highlight! NonText guifg=" .. COLORS['normal']['guibg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermbg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! NonText guifg=#4A4A4A guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=238 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# tabs
highlight! TabLine guifg=#bbbbbb guibg=#3c3f41 ctermfg=145 ctermbg=238 gui=NONE cterm=NONE term=NONE
highlight! TabLineSel guifg=#bbbbbb guibg=#4e5254 ctermfg=145 ctermbg=59 gui=NONE cterm=NONE term=NONE
highlight! TabLineFill guifg=#bbbbbb guibg=#3c3f41 ctermfg=145 ctermbg=238 gui=NONE cterm=NONE term=NONE

# TODO
execute "highlight! Folded guifg=#999999 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=102 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! FoldColumn guifg=#999999 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=102 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
# highlight! SyntaxFoldLevel guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE

execute "highlight! Directory guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

execute "highlight! Question guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

execute "highlight! MoreMsg guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

execute "highlight! Title guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# omnicompletion popup menu
highlight! Pmenu guifg=#bbbbbb guibg=#46484a ctermfg=145 ctermbg=238 gui=NONE cterm=NONE term=NONE
highlight! PmenuSel guifg=#bbbbbb guibg=#113a5c ctermfg=145 ctermbg=25 gui=NONE cterm=NONE term=NONE

# :help completepopup
highlight! InfoPopup guifg=#bbbbbb guibg=#333333 ctermfg=145 ctermbg=236 gui=NONE cterm=NONE term=NONE

# :terminal
highlight! link Terminal Normal
highlight! link StatusLineTerm StatusLine
highlight! link StatusLineTermNC StatusLineNC

# :help syntax
execute "highlight! Boolean guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Character guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Comment guifg=#999999 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=102 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Conditional guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Constant guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Debug guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Define guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Delimiter guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
highlight! Error guifg=white guibg=#ff0000 ctermfg=white ctermbg=196 gui=NONE cterm=NONE term=NONE
execute "highlight! Exception guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Float guifg=#6897bb guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=67 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Function guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Identifier guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Ignore guifg=black guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=black ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Include guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Keyword guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Label guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Macro guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Number guifg=#6897bb guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=67 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Operator guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! PreCondit guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! PreProc guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Repeat guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Special guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! SpecialChar guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! SpecialComment guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Statement guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! StorageClass guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! String guifg=#6a8759 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=65 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Structure guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Tag guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Todo guifg=#a8c023 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=142 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Type guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Typedef guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! Underlined guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=underline cterm=NONE term=NONE"

# signs column
highlight! SignColumn guifg=#606366 guibg=#313335 ctermfg=59 ctermbg=237 gui=NONE cterm=NONE term=NONE

# syntax errors/warnings
highlight! ErrorMsg guifg=white guibg=#ff0000 ctermfg=white ctermbg=1 gui=NONE cterm=NONE term=NONE
highlight! WarningMsg guifg=black guibg=#ffff00 ctermfg=black ctermbg=11 gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorClear guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxError guifg=black guibg=#ff0000 ctermfg=black ctermbg=9 gui=NONE cterm=NONE term=NONE
if &signcolumn == "number"
  execute "highlight! SyntaxWarning guifg=" .. COLORS['normal']['guifg'] .. " guibg=NONE ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=NONE gui=NONE cterm=NONE term=NONE"
else
  execute "highlight! SyntaxWarning guifg=" .. COLORS['normal']['guifg'] .. " guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
endif
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
  execute "highlight! SyntaxErrorSHELLCHECK guifg=" .. COLORS['normal']['guifg'] .. " guibg=NONE ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=NONE gui=NONE cterm=NONE term=NONE"
else
  execute "highlight! SyntaxErrorSHELLCHECK guifg=" .. COLORS['normal']['guifg'] .. " guibg=#4e5254 ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=59 gui=NONE cterm=NONE term=NONE"
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
  execute "highlight! SyntaxErrorPEP8 guifg=" .. COLORS['normal']['guifg'] .. " guibg=NONE ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=NONE gui=NONE cterm=NONE term=NONE"
else
  execute "highlight! SyntaxErrorPEP8 guifg=" .. COLORS['normal']['guifg'] .. " guibg=#4e5254 ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=59 gui=NONE cterm=NONE term=NONE"
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
  execute "highlight! SyntaxErrorGOVET guifg=" .. COLORS['normal']['guifg'] .. " guibg=NONE ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=NONE gui=NONE cterm=NONE term=NONE"
else
  execute "highlight! SyntaxErrorGOVET guifg=" .. COLORS['normal']['guifg'] .. " guibg=#4e5254 ctermfg=" .. COLORS['normal']['ctermfg'] .. " ctermbg=59 gui=NONE cterm=NONE term=NONE"
endif

# go syntax
# go#config#HighlightFunctions()
execute "highlight! goFunction guifg=#ffc66d guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=221 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! goReceiverVar guifg=#4eade5 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=74 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! goReceiverType guifg=#6fafbd guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=73 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
highlight! link goPointerOperator Normal

# go#config#HighlightFunctionParameters()
highlight! link goParamName Normal

# go#config#HighlightFunctionCalls()
# TODO ctermfg=137
execute "highlight! goFunctionCall guifg=#b09d79 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=137 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# go#config#HighlightTypes()
execute "highlight! goTypeConstructor guifg=#6fafbd guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=73 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
execute "highlight! goTypeDecl guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
highlight! link goTypeName Normal
execute "highlight! goDeclType guifg=#cc7832 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=172 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# go#config#HighlightFields()
execute "highlight! goField guifg=#6fafbd guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=73 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# go#config#HighlightBuildConstraints()
execute "highlight! goBuildKeyword guifg=#629755 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=64 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
highlight! link goBuildDirectives Normal

# go#config#HighlightGenerateTags()
execute "highlight! goGenerate guifg=#629755 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=64 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
# TODO
# goGenerateVariables points to Special

# custom
# see ~/.vim/after/syntax/go.vim
execute "highlight! goCustomFunctionName guifg=#afbf7e guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=144 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# vim syntax
execute "highlight! vimEnvVar guifg=#b09d79 guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=137 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"
highlight! link vimFunction    Normal
highlight! link vimFuncVar     Normal
highlight! link vimOption      Normal
highlight! link vimUserFunc    Normal
highlight! link vimVar         Normal
highlight! link vimFBVar       Normal
highlight! link vimHLGroup     Normal
highlight! link vimEchoHLNone  Normal
execute "highlight! vimFuncName guifg=#afbf7e guibg=" .. COLORS['normal']['guibg'] .. " ctermfg=144 ctermbg=" .. COLORS['normal']['ctermbg'] .. " gui=NONE cterm=NONE term=NONE"

# sh syntax
highlight! link shVariable        Normal
highlight! link shOption          Normal
highlight! link shFunction        Normal
highlight! link shShellVariables  Normal
highlight! link shQuote           String
# TODO match function color for function name() <--
# TODO match parenthesis colors if (( )) <--
