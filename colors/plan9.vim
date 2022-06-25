" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" My plan9 theme :)

" colors
" 230 (yellow plan9)
" 229 (yellow plan9 )
" 195 (cyan)
" 147 (purple)
" 144 (green/brown numbers)
" 187 (gray/brown clear)
" 243 (also we replace real darkgrey with 243 for now)
" 230 looks same as lightyellow
" 88 interesting red color
" 160 looks a red color
" 210 looks a red light color
" 98 with bold for numbers

" do not read the file if is already loaded
if exists('g:loaded_plan9') && g:loaded_plan9 == 1
  finish
endif
let g:loaded_plan9 = 1

" light background
if &background !=# "light"
  set background=light
endif

" clean up
highlight clear

if exists("syntax_on")
  syntax reset
endif

" colorscheme
let g:colors_name = "plan9"

highlight! Normal guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE

highlight! MatchParen guifg=black guibg=#afaf87 ctermfg=black ctermbg=144 gui=NONE cterm=NONE term=NONE

highlight! Visual guifg=black guibg=#ffffaf  ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE

highlight! WildMenu guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE

" split windows
highlight! StatusLine guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! StatusLineNC guifg=white guibg=gray ctermfg=white ctermbg=gray gui=NONE cterm=NONE term=NONE

" vertical split color
highlight! VertSplit guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! Cursor guifg=white guibg=#8888cc gui=NONE cterm=NONE term=NONE
highlight! CursorLine guifg=black guibg=#d7d7af ctermfg=black ctermbg=187 gui=NONE cterm=NONE term=NONE
highlight! CursorLineNR guifg=white guibg=#5f5f5f ctermfg=white ctermbg=black gui=bold cterm=bold term=NONE
highlight! link CursorColumn CursorLine

highlight! ColorColumn guifg=black guibg=#ffd75f ctermfg=black ctermbg=221 gui=NONE cterm=NONE term=NONE

highlight! SpellBad guifg=black guibg=#ff8787 ctermfg=black ctermbg=210 gui=NONE cterm=NONE term=NONE
highlight! SpellRare guifg=pink guibg=#ff8787" ctermfg=black ctermbg=210 gui=underline cterm=underline term=NONE
highlight! SpellCap guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=underline cterm=underline term=NONE

highlight! Search guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE

highlight! LineNr guifg=#afaf5f guibg=#ffffd7 ctermfg=143 ctermbg=230 gui=NONE cterm=NONE term=NONE

highlight! SpecialKey guifg=#d70000 guibg=#d7d7af ctermfg=160 ctermbg=187 gui=NONE cterm=NONE term=NONE

" diff (diffthis)
highlight! DiffText guifg=black guibg=#afafff ctermfg=black ctermbg=147 gui=NONE cterm=NONE term=NONE
highlight! DiffChange guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE
highlight! DiffDelete guifg=black guibg=#ff8787 ctermfg=black ctermbg=210 gui=NONE cterm=NONE term=NONE
highlight! DiffAdd guifg=black guibg=#afffaf ctermfg=black ctermbg=157 gui=NONE cterm=NONE term=NONE

highlight! Conceal guifg=black guibg=#ffff00 ctermfg=black ctermbg=226 gui=NONE cterm=NONE term=NONE

highlight! NonText guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE

highlight! TabLine guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! TabLineSel guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE
highlight! TabLineFill guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE

highlight! Folded guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE
highlight! FoldColumn guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE

highlight! Directory guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE

highlight! Question guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE

highlight! MoreMsg guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE

highlight! Title guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE

" omnicompletion popup menu
highlight! Pmenu guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! PmenuSel guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE

" see completepopup
highlight! InfoPopup guifg=black guibg=lightgray ctermfg=black ctermbg=lightgray gui=NONE cterm=NONE term=NONE

" adding color for :terminal
highlight! link Terminal Normal
highlight! StatusLineTerm guifg=white guibg=#005f00 ctermfg=white ctermbg=22 gui=NONE cterm=NONE term=NONE
highlight! link StatusLineTermNC StatusLineNC

" :help syntax
highlight! Boolean guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Character guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Comment guifg=grey39 guibg=#ffffd7 ctermfg=241 ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Conditional guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Constant guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Debug guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Define guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Delimiter guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Error guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Exception guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Float guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Function guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Identifier guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Ignore guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Include guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Keyword guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Label guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Macro guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Number guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Operator guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! PreCondit guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! PreProc guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Repeat guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Special guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! SpecialChar guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! SpecialComment guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Statement guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! StorageClass guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! String guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Structure guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Tag guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Todo guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Type guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Typedef guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE
highlight! Underlined guifg=black guibg=#ffffd7 ctermfg=black ctermbg=230 gui=NONE cterm=NONE term=NONE

" signs column
highlight! SignColumn guifg=black guibg=#afaf87 ctermfg=black ctermbg=144 gui=NONE cterm=NONE term=NONE

" created for syntax errors/warnings
highlight! ErrorMsg guifg=white guibg=#ff0000 ctermfg=white ctermbg=1 gui=NONE cterm=NONE term=NONE
highlight! WarningMsg guifg=black guibg=#ffff00 ctermfg=black ctermbg=11 gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorClear guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxError guifg=black guibg=#ff0000 ctermfg=black ctermbg=9 gui=NONE cterm=NONE term=NONE
highlight! SyntaxWarning guifg=black guibg=#ffffaf ctermfg=black ctermbg=lightyellow gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorPlus guifg=#800000 guibg=#ffffff ctermfg=1 ctermbg=15 gui=NONE cterm=NONE term=NONE

highlight! SyntaxGoodSH guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorSH guifg=white guibg=#ff0000 ctermfg=white ctermbg=196 gui=NONE cterm=NONE term=NONE

highlight! SyntaxGoodSHELLCHECK guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorSHELLCHECK guifg=black guibg=#d7d7af ctermfg=black ctermbg=187 gui=NONE cterm=NONE term=NONE

highlight! SyntaxGoodPY guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorPY guifg=white guibg=#ff0000 ctermfg=white ctermbg=196 gui=NONE cterm=NONE term=NONE

highlight! SyntaxGoodPEP8 guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorPEP8 guifg=black guibg=#d7d7af ctermfg=black ctermbg=187 gui=NONE cterm=NONE term=NONE

highlight! SyntaxGoodGO guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorGO guifg=white guibg=#ff0000 ctermfg=white ctermbg=196 gui=NONE cterm=NONE term=NONE

highlight! SyntaxGoodGOVET guifg=white guibg=black ctermfg=white ctermbg=black gui=NONE cterm=NONE term=NONE
highlight! SyntaxErrorGOVET guifg=black guibg=#d7d7af ctermfg=black ctermbg=187 gui=NONE cterm=NONE term=NONE

" statusline
highlight! SyntaxFoldLevel guifg=black guibg=#d7ffff ctermfg=black ctermbg=195 gui=NONE cterm=NONE term=NONE
