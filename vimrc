vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_vimrc')
  echohl WarningMsg
  echom $"Warning: the file '{expand('<sfile>:~')}' is already loaded"
  echom ":ReloadVimrc (to reload it)"
  echohl None
  finish
endif
g:loaded_vimrc = true

# autoload
import autoload './autoload/misc.vim'

# config variables
var colortheme = "darkula"                                                  # theme
var background = "dark"                                                     # background
var tmux = !empty($TMUX) || &term =~ "tmux"                                 # tmux
var screen = (!empty($STY) || &term =~ "screen") && !tmux                   # screen
var zellij = !empty($ZELLIJ) && !screen && !tmux                            # zellij
var multiplexer = screen || tmux || zellij                                  # multiplexer
var alacritty = !empty($ALACRITTY_SOCKET) && !multiplexer                   # alacritty
var alacritty_tmux = !empty($ALACRITTY_SOCKET) && tmux                      # alacritty + tmux
var alacritty_zellij = !empty($ALACRITTY_SOCKET) && zellij                  # alacritty + zellij
var apple_terminal = $TERM_PROGRAM == "Apple_Terminal"  && !multiplexer     # terminal.app
var apple_terminal_tmux = !empty($TERM_SESSION_ID) && tmux                  # terminal.app + tmux
var apple_terminal_zellij = !empty($TERM_SESSION_ID) && zellij              # terminal.app + zellij
var gnome_terminal = !empty($GNOME_TERMINAL_SCREEN) && !multiplexer         # gnome
var gnome_terminal_tmux = !empty($GNOME_TERMINAL_SCREEN) && tmux            # gnome + tmux
var gnome_terminal_zellij = !empty($GNOME_TERMINAL_SCREEN) && zellij        # gnome + zellij
var jediterm = $TERMINAL_EMULATOR == "JetBrains-JediTerm" && !multiplexer   # jediterm
var jediterm_tmux = $TERMINAL_EMULATOR == "JetBrains-JediTerm" && tmux      # jediterm + tmux
var jediterm_zellij = $TERMINAL_EMULATOR == "JetBrains-JediTerm" && zellij  # jediterm + zellij
var vim_terminal = !empty($VIM_TERMINAL)                                    # vim terminal
var vim_terminal_tmux = !empty($VIM_TERMINAL) && tmux                       # vim terminal + tmux
var vim_terminal_zellij = !empty($VIM_TERMINAL) && zellij                   # vim terminal + zellij
var xterm = !empty($XTERM_VERSION) && !multiplexer                          # xterm
var xterm_tmux = !empty($XTERM_VERSION) && tmux                             # xterm + tmux
var xterm_zellij = !empty($XTERM_VERSION) && zellij                         # xterm + zellij

# don't load defaults.vim
g:skip_defaults_vim = true

# disable built-in plugins
g:loaded_2html_plugin =  true     # tohtml.vim
g:loaded_getscriptPlugin = true   # getscriptPlugin.vim
g:loaded_gzip = true              # gzip.vim
g:loaded_logiPath = true          # logiPat.vim
g:loaded_matchparen = true        # matchparen.vim
g:loaded_netrw = true             # netrw autoload
g:loaded_netrwPlugin = true       # netrwPlugin.vim
g:loaded_rrhelper = true          # rrhelper.vim
g:loaded_spellfile_plugin = true  # spellfile.vim
g:loaded_tar = true               # pi_tar
g:loaded_tarPlugin = true         # tarPlugin.vim
g:loaded_vimball = true           # vimball autoload
g:loaded_vimballPlugin = true     # vimballPlugin.vim
g:loaded_zip = true               # zip.vim
g:loaded_zipPlugin = true         # zipPlugin.vim

# disable localisations (syntax=diff)
g:diff_translations = 0

# enable custom plugins
g:arrowkeys_enabled = true        # enable/disable arrow keys
g:autoclosechars_enabled = false  # automatic close of chars
g:autoendstructs_enabled = true   # automatic end of structures
g:bufferonly_enabled = true       # remove all buffers except the current one
g:checker_enabled = true          # checker plugin
g:commentarium_enabled = true     # comment by language
g:complementum_enabled = true     # complete by language
g:cyclebuffers_enabled = true     # cycle between buffers
g:documentare_enabled = true      # document information helper
g:esckey_enabled = true           # use key as escape
g:format_enabled = true           # format things
g:git_enabled = true              # git vcs
g:habit_enabled = true            # habit
g:misc_enabled = true             # miscelania functions
g:runprg_enabled = true           # run programs
g:scratch_enabled = true          # scratch stuff
g:se_enabled = true               # se plugin (simple explorer)
g:searcher_enabled = true         # search files and find matches
g:statusline_enabled = true       # statusline
g:tabline_enabled = true          # tab page
g:utils_enabled = true            # utils for misc plugin and generic use

# add plugins
# set packpath=$HOME/.vim,$VIMRUNTIME
const plugins = [
  'arrowkeys',
  'autoclosechars',
  'autoendstructs',
  'bufferonly',
  'checker',
  'commentarium',
  'complementum',
  'cyclebuffers',
  'documentare',
  'esckey',
  'format',
  'git',
  'habit',
  'runprg',
  'scratch',
  'se',
  'searcher',
  'tabline'
]
for plugin in plugins
  if get(g:, $"{plugin}_enabled")
    execute $"packadd! {plugin}"
  endif
endfor

# arrowkeys plugin
if g:arrowkeys_enabled
  g:arrowkeys_mode = "soft"  # soft, hard
endif

# checker plugin
if g:checker_enabled
  g:checker_showpopup = false
endif

# complementum plugin
if g:complementum_enabled
  g:complementum_debuginfo = false
endif

# cyclebuffers plugin
if g:cyclebuffers_enabled
  g:cyclebuffers_position = "bottom"  # top, bottom
endif

# esckey plugin
if g:esckey_enabled
  g:esckey_key = "<C-l>"
endif

# format plugin
if g:format_enabled
  g:format_python_command = ["black", "-S", "-l", "79"]  # 79 for pep8
endif

# git plugin
if g:git_enabled
  g:git_position = "top"  # top, bottom
endif

# habit plugin
if g:habit_enabled
  g:habit_mode = "soft"  # soft, hard
endif

# se plugin (simple explorer)
if g:se_enabled
  g:se_followfile = false
  g:se_hiddenfirst = false
  g:se_position = "left"  # left, right
  g:se_winsize = 20
endif

# statusline plugin
if g:statusline_enabled
  g:statusline_showgitbranch = true
endif

# global settings
set nocompatible            # use vim defaults instead of 100% vi compatibility
# set verbose=16            # if > 0; then vim will give debug messages
set debug=throw             # throw an exception on errors and set v:errmsg
set shortmess=a             # abbreviation status messages shorter (default filnxtToOS)
set shortmess+=I            # no vim splash
set shortmess+=c            # don't give ins-completion-menu messages
set cmdheight=1             # space for displaying status messages (default is 1)
set noerrorbells            # turn off error bells (do not bell on errors)
set belloff=all             # turn off error bells (do not bell on all events)
set novisualbell            # turn off visual bell (no sound, no visuals)
set title                   # update title window (dwm top bar)
set titlestring=%F          # when non-empty, sets the title of the window. it uses statusline syntax (default empty)
set titleold=               # do not show default title "thanks for flying vim" if set notitle
set noicon                  # the icon text of the window will not be set to the value of iconstring
set noallowrevins           # allow ctrl-_ in insert and cwmmand-line mode (default is off)
set noshowmode              # don't show current mode insert, command, replace, visual, etc
set noshowcmd               # don't show command on the last line of screen (ex: see visual mode)
set esckeys                 # allow usage of cursor keys within insert mode
set lazyredraw              # on: redraw only when needed, nice for editing macros
set linespace=0             # number of pixel lines inserted between characters (default is 0)
set autoread                # automatically read the file if it has been modified externally
# set autowrite             # write automatically the contents of the file if it has been modified (:make, <C-]> etc.)
# set autochdir             # change the current working directory when opening a file
set noruler                 # don't show line and column number (see statusline)
set magic                   # use extended regexp in search patterns
set modelines=0             # do not use modelines
set nomodeline              # avoid modeline vulnerability
set equalalways             # windows are automatically made the same size after splitting or closing a window
set helpheight=0            # zero disables this (default 20)
set formatoptions-=cro      # remove '"' line below automatically when current line is a comment (after/ftplugin/vim.vim)
set formatoptions+=j        # delete comment character when joining commented lines (:help fo-table) (default is tcq)
set nrformats-=octal        # do not recognize octal numbers for Ctrl-A and Ctrl-X
set scrolloff=5             # minimal number of screen lines to keep above and below the cursor (default is 5)
set sidescrolloff=5         # minimal number of screen columns to keep to the left and to the right of the cursor
set nostartofline           # some jump commands move the cursor to the first non-blank like <C-^> previous buffer
set nojoinspaces            # disable adding to spaces after '.' when joining a file, adding one instead of two
set nofixeol                # do not add an EOL at the end of file if missing, keep original file as is (default on)
set notimeout               # don't time out on :mappings
set ttimeout                # timeout off and ttimeout on -> time out on key codes
set ttimeoutlen=10          # wait time for key codes or maps (default 100ms ESC etc)
set keymodel=startsel       # using a shifted special key starts (<S-Left,Right,Up,Down>) (visual or select mode)
set keymodel+=stopsel       # using non shifted stops (visual or select mode)
set cpoptions-=aA           # don't set '#' alterative file for :read and :write
# set cpoptions+=n          # the column used for 'number' and 'relativenumber' will be used for text of wrapped lines
set number                  # print the line number in front of each line
# set relativenumber        # show the line number relative to the line
# set numberwidth=4         # minimal number of columns to use for the line number (default 4)
set laststatus=2            # to display the status line always
set display=lastline        # the last line in a window will be displayed if possible
set ignorecase              # case-insensitive search (also affects if == 'var', use if == 'var')
set noinfercase             # when ignorecase is on and doing completion, the typed text is adjusted accordingly
set smartcase               # except if start with capital letter
set tagcase=followscs       # default followic, (followscs follow the 'smartcase' and 'ignorecase' options)
set nofileignorecase        # case is not ignored when using file names and directories (default OS specific)
set hlsearch                # to highlight all search matches
set incsearch               # jumps to search word when typing on serch /foo (default no)
set nospell                 # disable spell checking
set spelloptions+=camel     # camel CaseWord is considered a separate word
set spellsuggest=best,15    # method and the maximum number of suggestions (default best)
set noshowmatch             # disable matching parenthesis
set matchtime=1             # seconds to show matching parenthesis
set matchpairs=(:),{:},[:]  # characters that form pairs (default)
set nofoldenable            # when off, all folds are open
set foldmethod=manual       # disable automatic folding
set foldopen-=block         # don't open folds when jumping with "(", "{", "[[", "[{", etc.
set foldlevelstart=99       # all folds open (default -1)
set cursorline              # mark with another color the current cursor line
set path=.,,,**             # set path for finding files with :find (default .,/usr/include,,)
set noemoji                 # don't consider unicode emoji characters to be full width
set updatetime=300          # used for the |CursorHold| autocommand event
set t_ut=                   # disable background color erase (BCE)
# set t_ti= t_te=           # do not restore screen contents when exiting Vim (see: help norestorescreen / xterm alternate screen)

# vim
if !has('gui_running')
  # viminfo with vim version
  execute $"set viminfofile={$HOME}/.viminfo_{v:version}"
  # cursor shapes
  # &t_SI = blinking vertical bar (INSERT MODE)
  # &t_SR = blinking underscore   (REPLACE MODE)
  # &t_EI = blinking block        (NORMAL MODE)
  if has('mac') && (
    alacritty || alacritty_tmux || alacritty_zellij
    || apple_terminal || apple_terminal_tmux || apple_terminal_zellij
  )
    &t_SI ..= "\eP\e[5 q\e\\"
    &t_SR ..= "\eP\e[3 q\e\\"
    &t_EI ..= "\eP\e[1 q\e\\"
  elseif (
    alacritty || alacritty_tmux || alacritty_zellij
    || gnome_terminal || gnome_terminal_tmux || gnome_terminal_zellij
    || jediterm || jediterm_tmux || jediterm_zellij
    || vim_terminal || vim_terminal_tmux || vim_terminal_zellij
    || xterm || xterm_tmux || xterm_zellij
  )
    &t_SI ..= "\e[6 q"
    &t_SR ..= "\e[4 q"
    &t_EI ..= "\e[2 q"
  endif
  # screen/tmux/alacritty mouse codes
  if match(&term, '^\(screen\|tmux\|alacritty\)') != -1
    # Terminal.app or xterm >= 277
    set ttymouse=sgr
  endif
  # automatically is on when term is xterm/screen (fast terminal)
  if match(&term, '^\(xterm\|screen\|tmux\|alacritty\)') != -1
    set ttyfast
  endif
  # italic fonts support
  if (xterm || apple_terminal) && !multiplexer
    &t_ZH = "\e[3m"
    &t_ZR = "\e[23m"
  endif
  # 24-bit terminal color
  if has('termguicolors') && str2nr(&t_Co) >= 256
    if (
      alacritty || alacritty_tmux || alacritty_zellij
      || gnome_terminal || gnome_terminal_tmux || gnome_terminal_zellij
      || jediterm || jediterm_tmux || jediterm_zellij
      || vim_terminal || vim_terminal_tmux || vim_terminal_zellij
      || xterm || xterm_tmux || xterm_zellij
    ) && !screen
      # :help xterm-true-color
      if !jediterm
        &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
        &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
      endif
      set termguicolors
    else
      set notermguicolors
    endif
  endif
endif

# gui
if has('gui_running')
  # see :SetGuiFont
  if has('gui_macvim')
    # viminfo with macvim version
    execute $"set viminfofile={$HOME}/.viminfo_macvim_{v:version}"
    # set guifont=SFMono-Regular:h16
    set guifont=Menlo\ Regular:h16
    set antialias
  else
    execute $"set viminfofile={$HOME}/.viminfo_gvim_{v:version}"
    # set guifont=SF\ Mono\ Medium\ 12
    set guifont=DejaVu\ Sans\ Mono\ 12
  endif
  set guicursor=a:blinkwait500-blinkon500-blinkoff500  # default is blinkwait700-blinkon400-blinkoff250
  set guioptions=acM                                   # do not load menus for gui (default aegimrLtT)
  set guiheadroom=0                                    # when zero, the whole screen height will be used by the window
  set mouseshape-=v:rightup-arrow                      # by default uses a left arrow that confuses
  set mouseshape+=v:beam                               # change it by beam shape (as in other apps)
  set mousehide                                        # hide the mouse pointer while typing (default on)
  set winaltkeys=no                                    # disable the access to menu gui entries by using the ALT key
endif

# if *syntax manual*, set it *before* filetype plugin on
# if *syntax on*, set it *after* filetype plugin on
# :help syn-manual
# enable syntax rules for specific files (setlocal syntax=ON/OFF)
# maximum column for syntax items (default 3000)
if has("syntax")
  syntax manual
  set synmaxcol=1024
endif

# see :filetype
if has("autocmd")
  filetype plugin indent on
endif

# default shell
if !empty($SHELL) && executable($SHELL)
  set shell=$SHELL
elseif executable("/bin/bash")
  set shell=/bin/bash
else
  set shell=/bin/sh
endif

# behavior of cursorline {line, number} (default both)
if exists('+cursorlineopt')
  set cursorlineopt=both
endif

# mouse support
if has('mouse')
  set mouse=a
endif

# prevents that the langmap option applies to characters (from defaults.vim)
if has("langmap") && exists("+langremap")
  set nolangremap
endif

# wildmenu
if has("wildmenu")
  set wildmenu                    # enchange command line completion
  set wildmode=longest:full,full  # default (full)
  set nowildignorecase            # case is not ignored when completing files and directories (see fileignorecase)
  set wildoptions=pum             # (pum) the completion matches are shown in a popup menu
  set wildignore=*.bmp,*.bz2,*.exe,*.gif,*.gz,*.jpg,*.jpeg,*.o,*.obj,*.pdf,*.png,*.pyc,*.swp,*.zip  # ignore these patterns
endif

# balloons
if has('balloon_eval') || has('balloon_eval_term')
  set noballooneval      # disable gui balloon support
  set noballoonevalterm  # disable non-gui balloon support
  set balloondelay=300   # delay in ms before a balloon may pop up
endif

# statusline
set showtabline=1  # to show tab only if there are at least two tabs (2 to show tab always) (default 1)
# custom tabline (see :help setting-tabline)
if get(g:, "tabline_enabled")
  set tabline=%!tabline#MyTabLine()
endif
# custom statusline
if get(g:, "statusline_enabled")
  # %{statusline#GetStatus()} vs %{statusline#statusline_full} vs g:statusline_full
  set statusline=%<%F\ %h%q%w%m%r%=%{&filetype}\ %{&fileencoding}[%{&fileformat}]%{get(g:,'statusline_full','')}\ %-15.(%l,%c%V%)\ %P
else
  set statusline=%<%F\ %h%m%r%=%{&filetype}\ %{&fileencoding}[%{&fileformat}]\ %-14.(%l,%c%V%)\ %P
endif

# utf-8 support
if has("multi_byte")
  set encoding=utf-8      # encoding editor
  set fileencoding=utf-8  # encoding buffer
  set termencoding=utf-8  # encoding terminal
  scriptencoding utf-8    # encoding script (must be after enconding)
endif

# show special characters (listchars must be after enconding configuration)
set nolist
if &encoding == "utf-8"
  set listchars=tab:»·,trail:¨,multispace:---+,precedes:<,extends:>
endif

# vertical seperator for vertical split windows
# fold for 'foldtext'
# eob removes the ~ after the last buffer line
set fillchars=vert:\ ,fold:-,eob:\  # \ contains one space!

# more powerful backspacing
set backspace=indent,eol,start

# wrapping
set nowrap               # disable wrap (enabled by default)
set nolinebreak          # don't wrap long lines using at character in 'breakat'
set showbreak=           # string to put at the start of wrapped lines. :set sbr=>\ contains one space! (default empty)
set breakindent          # wrapped lines will follow indentation
set breakindentopt+=sbr  # display the 'showbreak' value before the indentation

# tabs/spaces
set tabstop=2      # number of spaces a <tab> in the text stands for
set softtabstop=2  # if non-zero, number of spaces to insert for a <tab>
set shiftwidth=2   # number of spaces used for each step of (auto)indent
set shiftround     # round to shiftwidth for "<<" and ">>"
set expandtab      # expand <tab> to spaces in insert mode

# search files
# [l]grep[add][!]: grep -n $* /dev/null (default)
set grepprg=rg\ --vimgrep\ --line-number\ --no-heading\ --smart-case\ --color=never\ -uu\ --glob\ '!.git/'
set grepformat=%f:%l:%c:%m,%f:%l:%m

# backup files
set backup
set writebackup
set backupcopy=auto
set backupdir=$HOME/.vim/backups
set directory=$HOME/.vim/tmp//  # // use absolute path

# :help undo-persistence
if has('persistent_undo')
  set undofile                    # automatically save your undo history when you write a file
  set undolevels=1000             # default is 1000
  set undodir=$HOME/.vim/undodir  # directory to store undo files
endif

# history of commands and previous search patterns (defaults.vim is 200)
set history=200

# mksession options
if has('mksession')
  set sessionoptions-=options
  set sessionoptions-=localoptions
  set sessionoptions-=folds
  set sessionoptions-=terminal
  set sessionoptions+=resize,winpos
endif

# views options
set viewoptions-=options
set viewoptions-=localoptions
set viewoptions-=folds

# buffers
set hidden    # buffer becomes hidden when it is abandoned
set report=0  # show always the number of lines changed (default 2)
set confirm   # use dialog confirmation before exiting if files have not been saved
set more      # when on, listings pause when the whole screen is filled (default on)

# indent
set autoindent      # copy indent from current line when starting a new line
set copyindent      # copy the structure of the existing lines indent when autoindenting a new line
set preserveindent  # when changing the indent of the current line, preserve it if possible
# set smartindent   # clever autoindenting, works for C-like programs (see cinwords)

# :help ins-completion
# <C-x><C-o>
set omnifunc=syntaxcomplete#Complete
# <C-x><C-u>
set completefunc=syntaxcomplete#Complete

# completion
set completeopt=menuone,noinsert
if has('popupwin')
  set completeopt+=popup  # popup extra info, like using omnicompletion
endif
if exists('+completepopup')
  set completepopup+=highlight:InfoPopup  # see InfoPopUp in theme
endif
# .: the current buffer
# w: buffers in other windows
# b: other loaded buffers
# u: unloaded buffers
# k: dictionary files with dictionary option
# t: tags
# set complete=.,w,b,u,k,t
set complete=.,w,b,u,k
set pumheight=15  # maximum number of items to show in the popup menu (default 0)
set pumwidth=15   # minimum width to use for the popup menu (default 15)

# (empty) default vim clipboard
# * X11 primary clipboard (mouse middle button)
# + standard clipboard (firefox <C-c> <C-v>)
#
#                         YANK          delete,put,change    delete,put,change one line or more
# (empty)               "", "0             "", "-              "", "1
# unnamed               "", "0, "*         "", "-, "*          "", "1, "*
# unnamedplus           "", "0, "+         "", "-, "+          "", "1, "+
# unnamed,unnamedplus   "", "0, "*, "+     "", "-, "+          "", "1, "+

# use clipboard register '+' and also copies it to '*' (yank only)
if has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif

# signs
if has("signs")
  # draw only the sign column if contains signs
  set signcolumn=number
endif

#--------------
# key mapping |
#---------------------------------------------------------------------------"
# Commands / Modes | Normal | Insert | Command | Visual | Select | Operator |
#------------------|--------|--------|---------|--------|--------|----------|
# map  / noremap   |    x   |   -    |    -    |   x    |   x    |    x     |
# nmap / nnoremap  |    x   |   -    |    -    |   -    |   -    |    -     |
# vmap / vnoremap  |    -   |   -    |    -    |   x    |   x    |    -     |
# omap / onoremap  |    -   |   -    |    -    |   -    |   -    |    x     |
# xmap / xnoremap  |    -   |   -    |    -    |   x    |   -    |    -     |
# smap / snoremap  |    -   |   -    |    -    |   -    |   x    |    -     |
# map! / noremap!  |    -   |   x    |    x    |   -    |   -    |    -     |
# imap / inoremap  |    -   |   x    |    -    |   -    |   -    |    -     |
# cmap / cnoremap  |    -   |   -    |    x    |   -    |   -    |    -     |
#---------------------------------------------------------------------------"

# macOS default Terminal.app
# :help mac-lack
# <C-^> needs to be entered as <C-S-6>
# <C-@> needs to be entered as <C-S-2>

# mapping leaders
g:mapleader = "\<C-s>"

# alternative second leader
g:maplocalleader = "\<C-\>"

# the key that starts a <C-w> command in a terminal mode
# set termwinkey=<C-s>

# insert maps <cr> and <tab>
misc.MapInsertEnter()
misc.MapInsertTab()

# save
nnoremap <leader><C-w> :update<CR>
inoremap <leader><C-w> <C-\><C-o>:update<CR>

# search the selected text (:help visual-search)
# vnoremap <leader>* y/<C-r>"<CR>
# vnoremap <leader># y?<C-r>"<CR>
vnoremap <leader>* <ESC><ScriptCmd>misc.SearchSelectedText('forward')<CR>
vnoremap <leader># <ESC><ScriptCmd>misc.SearchSelectedText('backward')<CR>

# stop highlighting + clear and redraw the screen
nnoremap <C-l> :nohlsearch<CR><C-l>

# del
# <C-l> goes to normal mode in evim/insertmode
# <C-l> adds one character from the current match in completion
# delete forward to be like its analogous <C-h>
inoremap <expr> <C-l> (pumvisible() <bar><bar> &insertmode) ? '<C-l>' : '<DEL>'

# yank
# nnoremap Y y$

# edit
nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>eV :e $HOME/.vimrc.local<CR>
nnoremap <leader>et :execute "e " .. findfile(g:colors_name .. ".vim", $HOME .. "/.vim/**," .. $VIMRUNTIME .. "/**")<CR>
nnoremap <leader>eb :browse oldfiles<CR>
nnoremap <leader>e; mt$a;<ESC>`t
# nnoremap <leader>e* :e **/*

# completion
# :help ins-completion, ins-completion-menu, popupmenu-keys, complete_CTRL-Y
# see complementum plugin

# source
nnoremap <silent><leader>sv :ReloadVimrc<CR>
nnoremap <silent><leader>st :Theme<CR>
nnoremap <silent><leader>sa :ReloadVimrc<CR>:Theme<CR>

# toggle
nnoremap <leader>tgA :set autochdir! autochdir? \| echon " (set)"<CR>
nnoremap <leader>tgn :setlocal number! number? \| echon " (setlocal)"<CR>
nnoremap <leader>tgN :set number! number? \| echon " (set)"<CR>
nnoremap <leader>tgr :setlocal relativenumber! relativenumber? \| echon " (setlocal)"<CR>
nnoremap <leader>tgR :set relativenumber! relativenumber? \| echon " (set)"<CR>
nnoremap <leader>tgj :setlocal joinspaces! joinspaces?<CR>
nnoremap <leader>tgl :setlocal list! list? \| echon " (setlocal)"<CR>
nnoremap <leader>tgL :set list! list? \| echon " (set)"<CR>
nnoremap <leader>tgh :setlocal hlsearch! hlsearch?<CR>
nnoremap <leader>tgp :setlocal paste! paste?<CR>
nnoremap <leader>tgw :setlocal autowrite! autowrite?<CR>
nnoremap <leader># :nohlsearch<CR>
if g:misc_enabled
  nnoremap <leader>tgd <ScriptCmd>misc.DiffToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgs <ScriptCmd>misc.SyntaxToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgb <ScriptCmd>misc.BackgroundToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgc <ScriptCmd>misc.SignColumnToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgf <ScriptCmd>misc.FoldColumnToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgz <ScriptCmd>misc.FoldToggle()<CR>:echo v:statusmsg<CR>
endif

# :sh
if has('gui_running')
  if g:misc_enabled
    # nnoremap <silent><leader>sh <ScriptCmd>misc.SH()<CR>exec tmux -L gvim-builtin new-session -c $HOME -A -D -s default<CR>
    nnoremap <leader>sh <ScriptCmd>misc.SH()<CR>
  endif
else
  nnoremap <leader>sh :sh<CR>
endif

# terminal
#augroup event_terminal
#  autocmd!
#  autocmd TerminalOpen * setlocal nonumber norelativenumber signcolumn=no
#augroup END
nnoremap <silent><leader><CR> :below terminal<CR>
if has('gui_running')
  # nnoremap <silent><C-z> :below terminal<CR>
  # nnoremap <silent><C-z> <ScriptCmd>misc.SH()<CR>exec tmux -L gvim-builtin new-session -c $HOME -A -D -s default<CR>
  nnoremap <silent><C-z> :below terminal ++close /bin/sh -c "tmux -L gvim-terminal new-session -c $HOME -A -D -s default"<CR>
  nnoremap <silent><leader><C-CR> :below terminal<CR>
  nnoremap <silent><leader><S-CR> :below terminal ++close /bin/sh -c "tmux -L gvim-terminal new-session -c $HOME -A -D -s default"<CR>
  nnoremap <silent><leader><C-S-CR> :below terminal ++close /bin/sh -c "tmux -L gvim-terminal new-session -c $HOME -A -D -s default"<CR>
endif
nnoremap <silent><leader>z :terminal ++curwin ++noclose<CR>
nnoremap <silent><leader><C-z> :terminal ++curwin ++noclose<CR>

# move
nnoremap <leader><C-d> :move .+1<CR>==
nnoremap <leader><C-u> :move .-2<CR>==
inoremap <leader><C-d> <Esc>:move .+1<CR>==gi
inoremap <leader><C-u> <Esc>:move .-2<CR>==gi
vnoremap <leader><C-d> :move '>+1<CR>gv=gv
vnoremap <leader><C-u> :move '<-2<CR>gv=gv

# automatic close of chars
# inoremap ' ''<left>
# inoremap " ""<left>
# inoremap ( ()<left>
# inoremap [ []<left>
# inoremap { {}<left>
# inoremap {<CR> {<CR>}<C-\><C-o>O

# gui
if has('gui_running')
  if has('linux')
    map <S-Insert> <Nop>
    map! <S-Insert> <MiddleMouse>
  endif
  if g:misc_enabled
    nnoremap <leader><S-F10> <ScriptCmd>misc.GuiMenuBarToggle()<CR>:echo v:statusmsg<CR>
  endif
  tnoremap <C-Esc> <C-w>N
  tnoremap <C-d> <C-w>c
endif
nnoremap <leader>, :tabprevious<CR>
nnoremap <leader>. :tabnext<CR>
# *avoid* to use <Esc> mappings in terminal mode
# tnoremap <C-[> <C-w>N
# tnoremap <expr> <C-[> (&ft == "fzf") ? "<Esc>" : "<C-w>N"

# buffers
nnoremap <leader>n :bnext<CR>
nnoremap <leader><C-n> :bnext<CR>
nnoremap <leader>p :bprev<CR>
nnoremap <leader><C-p> :bprev<CR>
nnoremap <nowait><leader><leader> :b #<CR>
nnoremap <leader><C-g> 2<C-g>
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bD :bd!<CR>
nnoremap <leader>bw :bw<CR>
nnoremap <leader>bW :bw!<CR>
nnoremap <leader>ba :ball<CR>
nnoremap <leader>bs :sall<CR>
nnoremap <leader>bv :vertical ball<CR>
nnoremap <leader>bf :bfirst<CR>
nnoremap <leader>bl :blast<CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>
nnoremap <leader>bj :bnext<CR>:redraw!<CR>:ls<CR>
nnoremap <leader>bk :bprev<CR>:redraw!<CR>:ls<CR>
# go to N buffer (up to 9 for now)
# for i in range(1, 9)
#   if i <= 9 && g:misc_enabled
#     execute "nnoremap <leader>b" ..  i .. " <ScriptCmd>misc.GoBufferPos(" .. i .. ")<CR>"
#    endif
# endfor

# quickfix/location list
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprev<CR>
nnoremap <leader>cj :cnfile<CR>
nnoremap <leader>ck :cpfile<CR>
nnoremap <leader>co :copen<CR>
nnoremap <leader>lo :lopen<CR>
nnoremap <leader>cc :cclose<CR>
nnoremap <leader>lc :lclose<CR>
nnoremap <leader>cl :clist<CR>
nnoremap <leader>cf :cfirst<CR>
nnoremap <leader>ce :clast<CR>
nnoremap <leader>cx <ScriptCmd>setqflist([], 'r')<CR>
nnoremap <leader>lx <ScriptCmd>setloclist(0, [], 'r')<CR>

# popup window
nnoremap <leader>cP <ScriptCmd>popup_clear(1)<CR>

# case sensitive/insensitive
nnoremap <leader>ss /\C
nnoremap <leader>si /\c
if g:misc_enabled
  nnoremap <leader>sl <ScriptCmd>misc.MenuLanguageSpell()<CR>
endif

# diff (see copy-diff)
if g:misc_enabled
  nnoremap <localleader>dt <ScriptCmd>misc.DiffToggle()<CR>:echo v:statusmsg<CR>
endif
nnoremap <localleader>de :diffthis<CR>
nnoremap <localleader>dw :windo diffthis<CR>
nnoremap <localleader>dd :diffoff<CR>
nnoremap <localleader>dD :diffoff!<CR>
nnoremap <localleader>dg :DiffOrig<CR>
nnoremap <localleader>< :1,$+1diffget<CR>
nnoremap <localleader>> :1,$diffput<CR>
nnoremap <localleader>, :.,.diffget<CR>
nnoremap <localleader>. :.,.diffput<CR>
nnoremap <localleader>/ :diffupdate<CR>
command! DiffGetAll :1,$+1diffget
command! DiffPutAll :1,$diffput
command! DiffGetLine :.,.diffget
command! DiffPutLine :.,.diffput
# diff original file with unwritted changes (defaults.vim)
if !exists(":DiffOrig")
  command DiffOrig vertical new | set bt=nofile | silent! read ++edit %% | :0d _ | diffthis | wincmd p | diffthis
endif

# windows
nnoremap <leader>cw :close<CR>
nnoremap <leader>ch :helpclose<CR>
nnoremap <leader>ct :tabclose<CR>
nnoremap <leader><C-j> :resize +5<CR>
nnoremap <leader><C-k> :resize -5<CR>
nnoremap <leader><C-h> :vertical resize -5<CR>
nnoremap <leader><C-l> :vertical resize +5<CR>
command! SwapWindow execute "normal! \<C-w>x"

# grep using grepprg + quickfix
command! -nargs=+ -complete=file Grep execute "silent grep! <args>" | cwindow
command! -nargs=+ -complete=file Grepi {
  var grepprg_orig = &grepprg
  execute $"set grepprg={substitute(fnameescape(&grepprg), 'smart-case\|case-sensitive', 'ignore-case', '')}"
  execute "silent grep! <args>"
  execute $"set grepprg={fnameescape(grepprg_orig)}"
  cwindow
}

# find using searcher plugin
if g:searcher_enabled
  command! -nargs=+ -complete=file -bar Find searcher#Search(<q-args>, '-p', getcwd(), 'findprg', 'quickfix')
  command! -nargs=+ -complete=file -bar Findi searcher#Search('-i', <q-args>, '-p', getcwd(), 'findprg', 'quickfix')
endif

# edit file in the same directory as the active window one
nnoremap <leader>ee :e <C-r>=fnamemodify(expand('%:p:h'), ':~') .. '/'<CR>
# command! -nargs=1 -complete=customlist,misc#CompleteSameDir Ee e <args>
# cnoremap E e <C-r>=fnamemodify(expand('%:p:h'), ':~') .. '/'<CR>
cabbrev E e <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>
cabbrev Sp sp <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>
cabbrev Vs vsp <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>
cabbrev Tabe tabe <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>

# change to directory of the current file
nnoremap <silent><leader>cd :LCDC<CR>
nnoremap <silent><leader>cD :CDC<CR>
command! CDC cd %:p:h
command! LCDC lcd %:p:h

# menu misc
if g:misc_enabled
  nnoremap <silent><leader><F10> <ScriptCmd>misc.MenuMisc()<CR>
  nnoremap <silent><leader>f0 <ScriptCmd>misc.MenuMisc()<CR>
endif

# plan9 theme
command! Plan9 {
  g:loaded_plan9 = false
  set background=light
  colorscheme plan9
}

# darkula theme
command! Darkula {
  g:loaded_darkula = false
  set background=dark
  colorscheme darkula
}

# reload the current theme
command! Theme {
  if g:colors_name == "plan9"
    silent execute "normal! :Plan9\<CR>"
  elseif g:colors_name == "darkula"
    silent execute "normal! :Darkula\<CR>"
  else
    silent execute $"colorscheme {g:colors_name}"
  endif
}

# reload vimrc
command! ReloadVimrc {
  g:loaded_vimrc = false
  source $MYVIMRC
}

# reload plugin utils
command! ReloadPluginUtils {
  if get(g:, "utils_enabled")
    g:loaded_utils = false
    g:autoloaded_utils = false
    execute $"source {$HOME}/.vim/plugin/utils.vim"
    execute $"source {$HOME}/.vim/autoload/utils.vim"
  endif
}

# reload plugin misc
command! ReloadPluginMisc {
  if get(g:, "misc_enabled")
    g:loaded_misc = false
    g:autoloaded_misc = false
    execute $"source {$HOME}/.vim/plugin/misc.vim"
    execute $"source {$HOME}/.vim/autoload/misc.vim"
  endif
}

# set gui font (shows a gui panel to pick a font)
command! SetGuiFont if has('gui_running') | set guifont=* | endif

# vim events
if !has('gui_running')
  augroup event_vim
    autocmd!
    # reset the cursor shape and redraw the screen
    # autocmd VimEnter * ++once startinsert | stopinsert | redraw!
    # clear the terminal on exit
    if xterm
      autocmd VimLeave * ++once silent !printf '\e[0m'
    endif
  augroup END
endif

# load local config
var vimrc_local = $"{$HOME}/.vimrc.local"
if filereadable(vimrc_local)
  execute $"source {vimrc_local}"
endif

# set theme
execute $"set background={background}"
execute $"colorscheme {colortheme}"

# compile functions
defcompile
