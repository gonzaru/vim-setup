vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if !empty(get(b:, "current_syntax")) || !get(g:, "se_colors")
  finish
endif

# Se
if get(g:, 'colors_name') == "darkula"
  highlight! SeTop guifg=#8888cc guibg=NONE ctermfg=104 ctermbg=NONE gui=NONE cterm=NONE term=NONE
  highlight! SeDirectory guifg=#87afd7 guibg=NONE ctermfg=110 ctermbg=NONE gui=NONE cterm=NONE term=NONE
  highlight! SeDirectorySep guifg=#cc7832 guibg=NONE ctermfg=172 ctermbg=NONE gui=NONE cterm=NONE term=NONE
  highlight! SeFile guifg=#bbbbbb guibg=NONE ctermfg=145 ctermbg=NONE gui=NONE cterm=NONE term=NONE
  highlight! SeHidden guifg=#ff8787 guibg=NONE ctermfg=210 ctermbg=NONE gui=NONE cterm=NONE term=NONE
else
  highlight def link SeTop Normal
  highlight def link SeDirectory Normal
  highlight def link SeDirectorySep Normal
  highlight def link SeFile Normal
  highlight def link SeHidden Normal
endif

b:current_syntax = "se"
