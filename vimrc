vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_vimrc')
  echohl WarningMsg
  echomsg $"Warning: the file '{expand('<sfile>:~')}' is already loaded"
  echomsg ":ReloadVimrc (to reload it)"
  echohl None
  finish
endif
g:loaded_vimrc = true

# only *nix version
if !has('unix')
  finish
endif

# config variables
const colortheme = "darkula"                                                  # theme
const background = "dark"                                                     # background
const tabasesc = false                                                        # tab as escape
const host = hostname()                                                       # hostname
const sessiondir = $"{$HOME}/.vim/sessions"                                   # session dir
const tmux = !empty($TMUX) || &term =~ "tmux"                                 # tmux
const multiplexer = tmux                                                      # multiplexer
const alacritty = !empty($ALACRITTY_SOCKET) && !multiplexer                   # alacritty
const alacritty_tmux = !empty($ALACRITTY_SOCKET) && tmux                      # alacritty + tmux
const ghostty = $TERM_PROGRAM == "ghostty" && !multiplexer                    # ghostty
const ghostty_tmux = $TMUX_PARENT_TERM == "xterm-ghostty" && tmux             # ghostty + tmux
const apple_terminal = $TERM_PROGRAM == "Apple_Terminal"  && !multiplexer     # terminal.app
const apple_terminal_tmux = !empty($TERM_SESSION_ID) && tmux                  # terminal.app + tmux
const gnome_terminal = !empty($GNOME_TERMINAL_SCREEN) && !multiplexer         # gnome
const gnome_terminal_tmux = !empty($GNOME_TERMINAL_SCREEN) && tmux            # gnome + tmux
const jediterm = $TERMINAL_EMULATOR == "JetBrains-JediTerm" && !multiplexer   # jediterm
const jediterm_tmux = $TERMINAL_EMULATOR == "JetBrains-JediTerm" && tmux      # jediterm + tmux
const vimrc_local = $"{$HOME}/.vimrc.local"                                   # vimrc local config
const vim_terminal = !empty($VIM_TERMINAL) && !multiplexer                    # vim terminal
const vim_terminal_tmux = !empty($VIM_TERMINAL) && tmux                       # vim terminal + tmux
const xterm = !empty($XTERM_VERSION) && !multiplexer                          # xterm
const xterm_tmux = !empty($XTERM_VERSION) && tmux                             # xterm + tmux
const st = $TERM == "st-256color" && !multiplexer                             # st
const st_tmux = $TMUX_PARENT_TERM == "st-256color" && tmux                    # st + tmux

# don't load defaults.vim
g:skip_defaults_vim = true

# {filetype} = vim,go,python,etc...
# don't create mappings for the filetype ($VIMRUNTIME/ftplugin/{filetype}.vim)
# g:no_{filetype}_maps = true

# don't create mappings for all filetypes
# g:no_plugin_maps = true

# do not include the menu bar "Buffers"
# g:no_buffers_menu = true

# disable localisations (syntax=diff)
g:diff_translations = 0

# disable built-in plugins
g:loaded_2html_plugin = true       # tohtml.vim
g:loaded_getscriptPlugin = true    # getscriptPlugin.vim
g:loaded_gzip = true               # gzip.vim
g:loaded_logiPat = true            # logiPat.vim
g:loaded_manpager_plugin = true    # manpager.vim
g:loaded_matchparen = true         # matchparen.vim
g:loaded_matchit = true            # matchit.vim
g:loaded_netrw = true              # netrw autoload
g:loaded_netrwPlugin = true        # netrwPlugin.vim
g:loaded_openPlugin = true         # openPlugin.vim
g:loaded_rrhelper = true           # rrhelper.vim
g:loaded_spellfile_plugin = true   # spellfile.vim
g:loaded_tar = true                # pi_tar
g:loaded_tarPlugin = true          # tarPlugin.vim
g:loaded_tutor_mode_plugin = true  # tutor
g:loaded_vimball = true            # vimball autoload
g:loaded_vimballPlugin = true      # vimballPlugin.vim
g:loaded_zip = true                # zip.vim
g:loaded_zipPlugin = true          # zipPlugin.vim

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
g:habit_enabled = false           # habit
g:lsp_enabled = true              # lsp
g:menu_enabled = true             # menu options
g:misc_enabled = true             # miscelania functions
g:runprg_enabled = true           # run programs
g:scratch_enabled = true          # scratch stuff
g:se_enabled = true               # se plugin (simple explorer)
g:searcher_enabled = true         # search files and find matches
g:session_enabled = true          # session
g:statusline_enabled = true       # statusline
g:tabline_enabled = true          # tab page
g:utils_enabled = true            # utils for misc plugin and generic use
g:xkb_enabled = false             # xkb

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
  'lsp',
  'menu',
  'runprg',
  'scratch',
  'se',
  'searcher',
  'session',
  'tabline',
  'xkb'
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
  # g:complementum_keystroke_default = "\<C-x>\<C-n>"   # (default "\<C-n>")
  # g:complementum_keystroke_default_toggle = "\<C-n>"  # (default "\<C-x>\<C-n>")
  g:complementum_debuginfo = false
endif

# cyclebuffers plugin
if g:cyclebuffers_enabled
  g:cyclebuffers_position = "bottom"  # top, bottom
  g:cyclebuffers_oldfiles_limit = 15  # default is 0 (no limit)
endif

# darkula theme
if colortheme == "darkula"
  g:darkula_style = "dark"                # light or dark
  g:darkula_cursor2 = has('gui_running')  # alternative cursor n2
  g:darkula_pmenumatch2 = false           # pmenu match color n2
endif

# esckey plugin
if g:esckey_enabled
  # g:esckey_key = "<C-l>"
  if has('gui_running')
    g:esckey_key = "<F23>"
  else
    g:esckey_key = "<F3>"
  endif
endif

# format plugin
if g:format_enabled
  g:format_python_command = ["black", "-q", "-S", "-l", "79", "-"]  # 79 for pep8
  g:format_sh_on_write = false
  g:format_python_on_write = false
  g:format_go_on_write = true
endif

# git plugin
if g:git_enabled
  g:git_position = "top"  # top, bottom
endif

# habit plugin
if g:habit_enabled
  g:habit_mode = "soft"  # soft, hard
endif

# lsp plugin
if g:lsp_enabled
  g:lsp_complementum = true  # complementum plugin
endif

# menu plugin
if g:menu_enabled
  g:menu_add_menu_extra = true
endif

# se plugin (simple explorer)
if g:se_enabled
  g:se_colors = true
  g:se_dirsfirst = true
  g:se_followfile = false
  g:se_hiddenfirst = false
  g:se_position = "left"  # left, right
  g:se_resizemaxcol = false
  g:se_winsize = 25
endif

# searcher plugin
if g:searcher_enabled
  g:searcher_popup_fuzzy = false
endif

# session plugin
if g:session_enabled
  g:session_save_colorscheme = true
  g:session_save_menubar = true
endif

# statusline plugin
if g:statusline_enabled
  g:statusline_gitbranch = true
  g:statusline_gitstatusfile = true
endif

# xkb plugin
if g:xkb_enabled
  g:xkb_layout_first = "level3(caps_switch)"
  g:xkb_layout_next = "capslock(escape)"
  g:xkb_cmd_layout_first = ["setxkbsw", "-s", "0"]  # first
  g:xkb_cmd_layout_next = ["setxkbsw", "-s", "1"]   # next
  g:xkb_debug_info = false
endif

# global settings
set nocompatible            # use vim defaults instead of 100% vi compatibility
# set verbose=16            # if > 0; then vim will give debug messages
set debug=throw             # throw an exception on errors and set v:errmsg
set shortmess=a             # abbreviation status messages shorter (default filnxtToOS)
set shortmess+=I            # no vim splash
set shortmess+=c            # don't give ins-completion-menu messages
set shortmess+=C            # don't give messages while scanning for ins-completion
set shortmess+=t            # truncate message when necessary
set cmdheight=1             # space for displaying status messages (default is 1)
set noerrorbells            # turn off error bells (do not bell on errors)
set belloff=all             # turn off error bells (do not bell on all events)
set novisualbell            # turn off visual bell (no sound, no visuals)
set title                   # update title window (dwm top bar)
set titlestring=%F          # when non-empty, sets the title of the window. it uses statusline syntax (default: empty)
set titleold=               # do not show default title "thanks for flying vim" if set notitle
set noicon                  # the icon text of the window will not be set to the value of iconstring
set noallowrevins           # allow ctrl-_ in insert and command-line mode (default is off)
set noshowmode              # don't show current mode insert, command, replace, visual, etc
set noshowcmd               # don't show command on the last line of screen (ex: see visual mode)
set esckeys                 # allow usage of cursor keys within insert mode
set lazyredraw              # on: redraw only when needed, nice for editing macros
set linespace=0             # number of pixel lines inserted between characters (default is 0)
setglobal autoread          # automatically read the file if it has been modified externally
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
set commentstring=          # empty template for a comment (default /* %s */)
setglobal scrolloff=0       # minimal number of screen lines to keep above/below the cursor (0, defaults.vim 5, 999 center)
set sidescroll=0            # minimal number of columns to scroll horizontally (default 0)
setglobal sidescrolloff=0   # minimal number of screen columns to keep to the left and to the right of the cursor
# set smoothscroll          # scrolling using screen lines
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
set nonumber                # print the line number in front of each line
set relativenumber          # show the line number relative to the line
# set numberwidth=4         # minimal number of columns to use for the line number (default 4)
set laststatus=2            # to display the status line always
set display=lastline        # the last line in a window will be displayed if possible
set ignorecase              # case-insensitive search (also affects if == 'var', use if == 'var')
set smartcase               # except if start with capital letter
setglobal tagcase=followscs # default followic, (followscs follow the 'smartcase' and 'ignorecase' options)
set noinfercase             # when ignorecase is on and doing completion, the typed text is adjusted accordingly
set nofileignorecase        # case is not ignored when using file names and directories (default OS specific)
# set jumpoptions=stack     # make the jumplist behave like the tagstack
set hlsearch                # to highlight all search matches
nohlsearch                  # but stop highlighting initially
set incsearch               # jumps to search word when typing on serch /foo (default no)
set nospell                 # disable spell checking
# set spelllang=en,ru       # a comma-separated list of word list name (default "en"), see autoload/misc.vim -> SetImOptions()
set spelloptions+=camel     # camel CaseWord is considered a separate word
set spellsuggest=best,15    # method and the maximum number of suggestions (default best)
set noshowmatch             # disable matching parenthesis
set matchtime=1             # seconds to show matching parenthesis
set matchpairs=(:),{:},[:]  # characters that form pairs (default "(:),{:},[:]")
set nofoldenable            # when off, all folds are open
set foldmethod=manual       # disable automatic folding
set foldopen-=block         # don't open folds when jumping with "(", "{", "[[", "[{", etc.
set foldlevelstart=99       # all folds open (default -1)
set cursorline              # mark with another color the current cursor line
set cursorlineopt=both      # behavior of cursorline {line, number} (default both)
setglobal virtualedit=block # allow virtual editing in visual block mode <C-v> (default: empty)
setglobal path=.,,,**       # set path for finding files with :find (default .,/usr/include,,)
# set cdhome                # changes the current working directory to the $HOME like in Unix (default: off)
set noemoji                 # don't consider unicode emoji characters to be full width
set updatetime=300          # used for the |CursorHold| autocommand event
set t_ut=                   # disable background color erase (BCE)
# set t_ti= t_te=           # do not restore screen contents when exiting Vim (see: help norestorescreen / xterm alternate screen)

# tags
# echo tagfiles()
setglobal tags=./tags;,tags,./TAGS;,TAGS
set tagrelative

# vim
if !has('gui_running')
  # viminfo with vim version
  execute $"set viminfofile={$HOME}/.viminfo_{v:progname}-{v:version}"
  # cursor shapes
  # &t_SI = blinking vertical bar (INSERT MODE)
  # &t_SR = blinking underscore   (REPLACE MODE)
  # &t_EI = blinking block        (NORMAL MODE)
  if gnome_terminal || gnome_terminal_tmux
    || jediterm || jediterm_tmux
    || xterm || xterm_tmux
    &t_SI ..= "\e[6 q"
    &t_SR ..= "\e[4 q"
    &t_EI ..= "\e[2 q"
  else
    &t_SI ..= "\eP\e[5 q\e\\"
    &t_SR ..= "\eP\e[3 q\e\\"
    &t_EI ..= "\eP\e[1 q\e\\"
  endif
  # tmux/alacritty mouse codes
  if match(&term, '^\(tmux\|alacritty\|xterm-ghostty\)') != -1
    # Terminal.app or xterm >= 277
    set ttymouse=sgr
  endif
  # automatically is on when term is xterm (fast terminal)
  if match(&term, '^\(xterm\|tmux\|alacritty\)') != -1
    set ttyfast
  endif
  # italic fonts support
  if (empty(&t_ZH) || empty(&t_ZR)) && (xterm || apple_terminal) && !multiplexer
    &t_ZH ..= "\e[3m"
    &t_ZR ..= "\e[23m"
  endif
  # 24-bit terminal color
  if has('termguicolors') && str2nr(&t_Co) >= 256
    if (
      alacritty || alacritty_tmux
      || ghostty || ghostty_tmux
      || gnome_terminal || gnome_terminal_tmux
      || jediterm || jediterm_tmux
      || vim_terminal || vim_terminal_tmux
      || xterm || xterm_tmux
      || st || st_tmux
    )
      # :help xterm-true-color
      if !jediterm && (empty(&t_8f) || empty(&t_8b))
        &t_8f ..= "\e[38:2:%lu:%lu:%lum"
        &t_8b ..= "\e[48:2:%lu:%lu:%lum"
      endif
      set termguicolors
    else
      set notermguicolors
    endif
  endif
  # FocusGained, FocusLost (see :help xterm-focus-event)
  if alacritty || alacritty_tmux || ghostty || ghostty_tmux || st || st_tmux
    &t_fe ..= "\e[?1004h"
    &t_fd ..= "\e[?1004l"
    execute "set <FocusGained>=\<Esc>[I"
    execute "set <FocusLost>=\<Esc>[O"
  else
    &t_fe = ""
    &t_fd = ""
  endif
  # disable xon/xoff handshaking (<C-s>)
  &t_xo = ""
  # enable modifyOtherKeys level 2 (see :help modifyOtherKeys)
  # <C-Tab>, <C-S-Tab>
  if alacritty || alacritty_tmux
    &t_ti ..= "\<Esc>[>4;2m"
    &t_te ..= "\<Esc>[>4;m"
  endif
endif

# gui
if has('gui_running')
  # see :SetGuiFont
  if has('gui_macvim')
    # viminfo with macvim version
    # set guifont=SFMono-Regular:h16
    set guifont=Menlo\ Regular:h16
    # set antialias
  else
    if filereadable($"{$HOME}/.local/share/fonts/SF-Mono-Medium.otf")
      execute $"set guifont=SF\\ Mono\\ Medium\\ {host == 'vologda' ? 12.5 : 12}"
    else
      execute $"set guifont=DejaVu\\ Sans\\ Mono\\ {host == 'vologda' ? 12.8 : 12}"
    endif
  endif
  execute $"set viminfofile={$HOME}/.viminfo_{v:progname}-{v:version}"
  var keep_guioptions = exists('g:guioptions_save') && &guioptions =~ "m"  # menu bar is present
  g:guifont_save = &guifont
  g:guioptions_save = &guioptions
  set guicursor=a:blinkwait500-blinkon500-blinkoff500  # default is blinkwait700-blinkon400-blinkoff250
  if !keep_guioptions
    set guioptions=acdgkM!                             # do not load menus for gui (default: aegimrLtT)
  endif
  set guiheadroom=0                                    # when zero, the whole screen height will be used by the window
  set mouseshape-=v:rightup-arrow                      # by default uses a left arrow that confuses
  set mouseshape+=v:beam                               # change it by beam shape (as in other apps)
  set nomousefocus                                     # mouse pointer is active automatically on the focused window
  set mousehide                                        # hide the mouse pointer while typing (default: on)
  set winaltkeys=no                                    # disable the access to menu gui entries by using the ALT key
  # set browsedir=buffer                               # use the directory of the related buffer (default: last)
endif

# if *syntax manual*, set it *before* filetype plugin on
# if *syntax on*, set it *after* filetype plugin on
# :help syn-manual
# enable syntax rules for specific files (setlocal syntax=ON/OFF)
# maximum column for syntax items (default: 3000)
if has("syntax")
  syntax manual
  # debug :syntime on, :syntime report
  # .vim/after/syntax
  # syntax sync fromstart
  set synmaxcol=256
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
elseif executable("bash")
  set shell=/usr/bin/env\ bash
else
  set shell=/bin/sh
endif
# set shellpipe=>%s\ 2>&1  # (default: 2>&1| tee)

# mouse support
if has('mouse')
  set mouse=a
  set mousemodel=extend
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
  setglobal listchars=tab:»·,trail:¨,multispace:---+,precedes:<,extends:>
endif

# keyboard layout (see :help i_CTRL-^)
if has('keymap') && has("langmap") && exists("+langremap")
  set nolangremap               # prevents that the langmap option applies to characters (defaults.vim)
  # set keymap=russian-jcuken   # XFree86 'ru' keymap compatible (see inoremap <C-^>)
  set iminsert=0                # 0 lmap is off and IM is off (default: 0)
  set imsearch=-1               # 0 lmap is off and IM is off (default: -1)
  # set imstatusfunc=SetImFunc  # called to obtain the status of input method
  # TODO <leader><C-^>
  inoremap <C-^> <Cmd>if empty(&keymap) <bar> set keymap=russian-jcuken <bar> endif<CR><C-^><ScriptCmd>misc#SetImOptions()<CR>
endif

# wildmenu
if has("wildmenu")
  set wildchar=<Tab>              # character to type to start wildcard expansion (default: <Tab>)
  set wildcharm=<C-z>             # like 'wildchar' but it works in macros and mappings (<C-z> becomes <Tab>)
  set wildmenu                    # enchange command line completion
  set wildmode=longest:full,full  # for bash alike use "wildmode=list:longest,full" (default: full)
  set wildignorecase              # case is ignored when completing files and directories (see fileignorecase)
  set wildoptions=pum             # (pum) the completion matches are shown in a popup menu
  set wildoptions+=fuzzy          # (fuzzy) fuzzy matching
  set wildignore=*.bmp,*.bz2,*.exe,*.gif,*.gz,*.jpg,*.jpeg,*.o,*.obj,*.pdf,*.png,*.pyc,*.swp,*.zip  # ignore these patterns
endif

# balloons
if has('balloon_eval') || has('balloon_eval_term')
  set noballooneval      # disable gui balloon support
  set noballoonevalterm  # disable non-gui balloon support
  set balloondelay=300   # delay in ms before a balloon may pop up
endif

# statusline
set showtabline=1  # to show tab only if there are at least two tabs (2 to show tab always) (default: 1)
# custom tabline (see :help setting-tabline)
if get(g:, "tabline_enabled")
  set tabline=%!tabline#MyTabLine()
endif
# custom statusline
if get(g:, "statusline_enabled")
  # %{statusline#GetStatus()} vs %{statusline#statusline_full} vs g:statusline_full
  setglobal statusline=%<%F\ %h%q%w%m%r%=%{!empty(v:this_session)?'*'..fnamemodify(v:this_session,':t:r'):''}\ %{&filetype}\ %{&fileencoding}[%{&fileformat}]%{get(g:,'statusline_full','')}%{statusline#GetImOptions('lang',1)}\ %{statusline#ShortPath(fnamemodify(getcwd(),':~'))}\ %-14.(%l,%c%V%)\ %P
else
  setglobal statusline=%<%F\ %h%m%r%=%{!empty(v:this_session)?'*'..fnamemodify(v:this_session,':t:r'):''}\ %{&filetype}\ %{&fileencoding}[%{&fileformat}]\ %{fnamemodify(getcwd(),':~')}\ %-14.(%l,%c%V%)\ %P
endif

# vertical seperator for vertical split windows
# fold for 'foldtext'
# eob removes the ~ after the last buffer line
setglobal fillchars=vert:\ ,fold:-,eob:\  # \ contains one space!

# more powerful backspacing
set backspace=indent,eol,start

# wrapping
set nowrap               # disable wrap (enabled by default)
set nolinebreak          # don't wrap long lines using at character in 'breakat'
setglobal showbreak=     # string to put at the start of wrapped lines. :set sbr=>\ contains one space! (default: empty)
set breakindent          # wrapped lines will follow indentation
set breakindentopt+=sbr  # display the 'showbreak' value before the indentation

# tabs/spaces (see :retab)
set tabstop=2      # number of spaces a <tab> in the text stands for
set softtabstop=2  # if non-zero, number of spaces to insert for a <tab>
set shiftwidth=2   # number of spaces used for each step of (auto)indent
set shiftround     # round to shiftwidth for "<<" and ">>"
set expandtab      # expand <tab> to spaces in insert mode
set smarttab       # inserts blanks according to shiftwidth

# search files
# [l]grep[add][!]: grep -n $* /dev/null  (default)
# %f:%l:%m,%f:%l%m,%f  %l%m (default)
# --vimgrep
setglobal grepprg=rg\ --with-filename\ --line-number\ --column\ --no-heading\ --smart-case\ --color=never\ -uu\ --glob\ '!.git/'
setglobal grepformat=%f:%l:%c:%m

# backup files
set backup
set writebackup
setglobal backupcopy=yes
set backupext=~                   # (default: "~")
set backupdir=$HOME/.vim/backups
set directory=$HOME/.vim/tmp//    # // use absolute path

# :help undo-persistence
if has('persistent_undo')
  set undofile                    # automatically save your undo history when you write a file
  setglobal undolevels=1000       # (default: 1000)
  set undodir=$HOME/.vim/undodir  # directory to store undo files
endif

# history of commands and previous search patterns (defaults.vim is 200)
set history=200

# mksession options
# (default:  blank,buffers,curdir,folds,help,options,tabpages,winsize,terminal)
set sessionoptions=buffers,curdir,tabpages,winsize

# views options
# (default: folds,options,cursor,curdir)
set viewdir=$HOME/.vim/view
set viewoptions-=options
set viewoptions-=localoptions
set viewoptions-=folds
set viewoptions-=curdir

# buffers
set hidden    # buffer becomes hidden when it is abandoned
set report=0  # show always the number of lines changed (default: 2)
set confirm   # use dialog confirmation before exiting if files have not been saved
set more      # when on, listings pause when the whole screen is filled (default: on)

# indent
set autoindent      # copy indent from current line when starting a new line
set copyindent      # copy the structure of the existing lines indent when autoindenting a new line
set preserveindent  # when changing the indent of the current line, preserve it if possible
# set smartindent   # clever autoindenting, works for C-like programs (see cinwords)

# :help ins-completion
# setglobal autocomplete  # shows a completion menu as you type:
# set iskeyword+=-        # keywords (default: "@,48-57,_,192-255")
# <C-x><C-o>
# set omnifunc=syntaxcomplete#Complete
# <C-x><C-u>
# set completefunc=syntaxcomplete#Complete

# completion
setglobal dictionary=spell,${HOME}/.vim/dict/lang/en  # lookup words (<C-x><C-k>)
setglobal completeopt=menuone,noselect  # noinsert,nearest <> fuzzy,nosort,longest (with autocomplete)
if exists('&completefuzzycollect')
  set completefuzzycollect=
  if &completeopt =~ 'fuzzy'
    set completefuzzycollect+=keyword
  endif
endif
if has('popupwin')
  # setglobal completeopt+=popup      # show extra information in a popup window
  # https://github.com/vim/vim/issues/18442
  if !has('gui_running')
    setglobal completeopt+=popuphidden  # like popup option but hidden by default
  endif
  inoremap <expr> <silent> <C-f> pumvisible() ? '<ScriptCmd>misc#PopupToggle()<CR>' : '<C-f>'
  if exists('+completepopup')
    set completepopup=
    set completepopup+=border:off,resize:off
    augroup event_colorscheme
      autocmd!
      autocmd ColorScheme * ++once {
        # (default: highlight:PmenuSel)
        if hlexists('InfoPopup')
          set completepopup+=highlight:InfoPopup
        else
          set completepopup+=highlight:Pmenu
        endif
      }
      augroup END
  endif
endif
# .: the current buffer
# w: buffers in other windows
# b: other loaded buffers
# u: unloaded buffers
# k: dictionary files with dictionary option
# t: tags
# set complete=.,w,b  # (default: .,w,b,u,k,t)
set complete=.^10,w^5,b^5,u^5
set pumborder=    # defines a border for the popup (default: empty) (hl-PmenuBorder, hl-PmenuShadow)
set pumheight=15  # maximum number of items to show in the popup menu (default: 0)
set pumwidth=15   # minimum width to use for the popup menu (default: 15)

# (empty) default vim clipboard
# * X11 primary clipboard (mouse middle button)
# + standard clipboard (firefox <C-c> <C-v>)
#
#                         YANK          delete,put,change    delete,put,change one line or more
# (empty)               "", "0             "", "-              "", "1
# unnamed               "", "0, "*         "", "-, "*          "", "1, "*
# unnamedplus           "", "0, "+         "", "-, "+          "", "1, "+
# unnamed,unnamedplus   "", "0, "*, "+     "", "-, "+          "", "1, "+

# use clipboard register '+' and also copies it to '*' (yank only) (see :help W23)
if has('X11') && has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif

# signs
if has("signs")
  # draw only the sign column if contains signs
  set signcolumn=number
endif

# +-------------+
# | key mapping |
# +-------------+-----------------------------------------------------------------------------------+
# | Commands / Modes | Normal | Insert | Command | Visual | Select | Operator | Terminal | Lang-Arg |
# +------------------|--------|--------|---------|--------|--------|----------|----------|----------+
# | map  / noremap   |    x   |   -    |    -    |   x    |   x    |    x     |    -     |    -     |
# | nmap / nnoremap  |    x   |   -    |    -    |   -    |   -    |    -     |    -     |    -     |
# | vmap / vnoremap  |    -   |   -    |    -    |   x    |   x    |    -     |    -     |    -     |
# | omap / onoremap  |    -   |   -    |    -    |   -    |   -    |    x     |    -     |    -     |
# | xmap / xnoremap  |    -   |   -    |    -    |   x    |   -    |    -     |    -     |    -     |
# | smap / snoremap  |    -   |   -    |    -    |   -    |   x    |    -     |    -     |    -     |
# | map! / noremap!  |    -   |   x    |    x    |   -    |   -    |    -     |    -     |    -     |
# | imap / inoremap  |    -   |   x    |    -    |   -    |   -    |    -     |    -     |    -     |
# | lmap / lnoremap  |    -   |   x    |    x    |   -    |   -    |    -     |    -     |    x     |
# | cmap / cnoremap  |    -   |   -    |    x    |   -    |   -    |    -     |    -     |    -     |
# | tmap / tnoremap  |    -   |   -    |    -    |   -    |   -    |    -     |    x     |    -     |
# +-------------------------------------------------------------------------------------------------+

# macOS default Terminal.app
# :help mac-lack
# <C-^> needs to be entered as <C-S-6>
# <C-@> needs to be entered as <C-S-2>

# mapping leaders
g:mapleader = "\<C-s>"  # (see terminal "stty -ixon" and &t_xo)

# alternative second leader
g:maplocalleader = "\<C-_>"

# the key that starts a <C-w> command in a terminal mode
# set termwinkey=<C-s>

# insert maps <bs>, <cr>, <space> and <tab>
# misc#MapInsertBackSpace()
# misc#MapInsertEnter()
# misc#MapInsertSpace()
# misc#MapInsertTab()
# inoremap <expr> <silent> <Tab> pumvisible() ? '<C-y>' : '<Tab>'
# inoremap <expr> <silent> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
# inoremap <expr> <silent> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'
# completion for lsp with <BS>, see CompleteKey (complementum plugin)
# inoremap <expr> <silent> <BS> get(g:, 'complementum_enabled') ? '<Plug>(complementum-backspace)' : '<BS>'
def MapInsertTab(mode: string): string
  var keystroke = "\<Tab>"
  if get(g:, 'loaded_copilot') && !empty(copilot#GetDisplayedSuggestion().text)
    keystroke = copilot#Accept()
  elseif pumvisible()
    var info = complete_info()
    if info.selected == -1 || &completeopt =~ 'noselect'
      if mode == 'tab'
        keystroke = "\<C-n>"
      elseif mode == 'stab'
        keystroke = "\<C-p>"
      endif
    else
      keystroke = "\<C-y>"
    endif
  endif
  return keystroke
enddef
if tabasesc && (has('gui_running') || (&t_ti =~ "\<Esc>[>4;2m" && &t_te =~ "\<Esc>[>4;m"))
  inoremap <silent> <C-i> <C-r>=<SID>MapInsertTab("tab")<CR>
  inoremap <silent> <C-Tab> <C-r>=<SID>MapInsertTab("tab")<CR>
  inoremap <Tab> <C-\><C-n>
  vnoremap <Tab> <C-\><C-n>gV
  cnoremap <C-Tab> <C-c><C-\><C-n>
  # inoremap <Esc> <Nop>
  # vnoremap <Esc> <Nop>
  # cnoremap <Esc> <Nop>
else
  # inoremap <silent> <Tab> <C-r>=<SID>MapInsertTab("tab")<CR>
  inoremap <silent> <expr> <Tab> <SID>MapInsertTab('tab')
  inoremap <silent> <expr> <S-Tab> <SID>MapInsertTab('stab')
endif

# save
nnoremap <leader><C-u> :update<CR>
inoremap <leader><C-u> <Cmd>update<CR>
nnoremap <leader><C-b> :Backup<CR>
command! Backup {
  var bak = $"{&backupdir}/{expand('%:t')}-{strftime('%Y%m%d%H%M%S')}{&backupext}"
  execute $"write {bak}"
}
command! Please {
  var msg = "Are you sure to write it using sudo? (yes, no): "
  if input(msg) == "yes"
    write !sudo /usr/bin/tee % >/dev/null
    edit!
    feedkeys("\<CR>", "n")
  endif
  redraw!
}

# sessions
# see session plugin

# search & replace
nnoremap <leader>% :%s/\<<C-r>=expand("<cword>")<CR>\>//g<Left><Left>

# search the selected text (:help visual-search)
# vnoremap <leader>* y/<C-r>"<CR>
# vnoremap <leader># y?<C-r>"<CR>
vnoremap <leader>* <C-\><C-n><ScriptCmd>misc#SearchSelectedText('forward')<CR>
vnoremap <leader># <C-\><C-n><ScriptCmd>misc#SearchSelectedText('backward')<CR>

# show the name of highlighting groups
nnoremap <leader>hg :echo join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), ",")<CR>

# stop highlighting + update diff (if present) + clear and redraw the screen
nnoremap <silent> <leader><C-l> :nohlsearch <bar> if &l:diff <bar> diffupdate <bar> endif<CR><C-l>

# del
# <C-l> goes to normal mode in evim/insertmode
# <C-l> adds one character from the current match in completion
# delete forward to be like its analogous <C-h>
inoremap <expr> <C-l> (pumvisible() <bar><bar> &insertmode) ? '<C-l>' : '<DEL>'

# yank
# nnoremap Y y$

# paste
# useful when in a termimal
command! Paste {
  var keeppaste = &l:paste
  setlocal paste
  normal! "+p
  if !keeppaste
    setlocal nopaste
  endif
}

# edit
nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>eV <ScriptCmd>if filereadable(vimrc_local) <bar> execute $"e {vimrc_local}" <bar> endif<CR>
nnoremap <leader>et :execute "e " .. findfile(g:colors_name .. ".vim", $HOME .. "/.vim/**," .. $VIMRUNTIME .. "/**")<CR>
nnoremap <leader>eb :browse oldfiles<CR>
nnoremap <leader>e; mt$a;<C-\><C-n>`t
# nnoremap <leader>e* :e **/*

# man
if g:runprg_enabled
  command! -nargs=1 -complete=shellcmd Man runprg#RunWindow($'man {<f-args>}', '', 'above', v:true)
endif

# completion
# :help ins-completion, ins-completion-menu, popupmenu-keys, complete_CTRL-Y
# see complementum plugin

# abbreviation
# <C-v> prevent an abbreviation from expanding (<C-]> expands it)
# inoremap <silent> <Space> <C-v><Space>

# source
nnoremap <silent> <leader>sv :ReloadVimrc<CR>
nnoremap <silent> <leader>sV :ReloadVimrcLocal<CR>
nnoremap <silent> <leader>st :ReloadTheme<CR>
nnoremap <silent> <leader>sa :ReloadVimrc<CR>
                            \:ReloadVimrcLocal<CR>
                            \:ReloadTheme<CR>
                            \:ReloadSyntax<CR>
                            \:ReloadPluginUtils<CR>
                            \:ReloadPluginMisc<CR>
                            \:MiscReloadPluginsOptAll<CR>
                            \:MiscReloadPluginsStartAll<CR>
                            \:ReloadFileType<CR>
                            \:doautocmd <nomodeline> BufEnter<CR>
# toggle
nnoremap <leader>tgA :set autochdir! autochdir? <bar> echon " (set)"<CR>
nnoremap <leader>tgn :setlocal number! number? <bar> echon " (setlocal)"<CR>
nnoremap <leader>tgN :set number! number? <bar> echon " (set)"<CR>
nnoremap <leader>tgr :setlocal relativenumber! relativenumber? <bar> echon " (setlocal)"<CR>
nnoremap <leader>tgR :set relativenumber! relativenumber? <bar> echon " (set)"<CR>
nnoremap <leader>tgi :setlocal infercase! infercase? <bar> echon " (setlocal)"<CR>
nnoremap <leader>tgI :set infercase! infercase? <bar> echon " (set)"<CR>
nnoremap <leader>tgJ :set joinspaces! joinspaces? <bar> echon " (set)"<CR>
nnoremap <leader>tgl :setlocal list! list? <bar> echon " (setlocal)"<CR>
nnoremap <leader>tgL :set list! list? <bar> echon " (set)"<CR>
nnoremap <leader>tgH :set hlsearch! hlsearch? <bar> echon " (set)"<CR>
nnoremap <leader>tgP :set paste! paste? <bar> echon " (set)"<CR>
nnoremap <leader>tgW :set autowrite! autowrite? <bar> echon " (set)"<CR>
# nnoremap <leader># :nohlsearch<CR>
if g:misc_enabled
  nnoremap <leader>tgd <ScriptCmd>misc#DiffToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgs <ScriptCmd>misc#SyntaxToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgb <ScriptCmd>misc#BackgroundToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgo <ScriptCmd>misc#SignColumnToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgf <ScriptCmd>misc#FoldColumnToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgz <ScriptCmd>misc#FoldToggle()<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgy <ScriptCmd>misc#FuzzyToggle("completeopt")<CR>:echo v:statusmsg<CR>
  nnoremap <leader>tgY <ScriptCmd>misc#FuzzyToggle("wildoptions")<CR>:echo v:statusmsg<CR>
  nnoremap <expr> <leader>tgm
  \ has('gui_running')
  \ ? '<ScriptCmd>misc#GuiMenuBarToggle()<CR>:echo v:statusmsg<CR>'
  \ : '<ScriptCmd>misc#CmdMenuBarToggle()<CR>:echo v:statusmsg<CR>'
  nnoremap <leader>tgM <ScriptCmd>misc#CmdMenuBarToggle()<CR>:echo v:statusmsg<CR>
endif

# :sh
if has('gui_running')
  if g:misc_enabled
    # nnoremap <silent> <leader>sh <ScriptCmd>misc#SH()<CR>exec tmux -L gvim-builtin new-session -c $HOME -A -D -s gvim-builtin<CR>
    nnoremap <leader>sh <ScriptCmd>misc#SH()<CR>
  endif
else
  nnoremap <leader>sh :sh<CR>
endif

# terminal
# augroup event_terminal
#   autocmd!
#   # TODO: laststatus=0
#   autocmd TerminalWinOpen * setlocal nonumber norelativenumber signcolumn=no statusline=%#Normal#
# augroup END
if has('gui_running')
  if has('linux') || has('bsd')
    map <S-Insert> <Nop>
    map! <S-Insert> <MiddleMouse>
    tnoremap <S-Insert> <C-w>"+
  endif
  # nnoremap <silent> <leader><CR> <ScriptCmd>misc#SH()<CR>exec tmux -L gvim-builtin new-session -c $HOME -A -D -s gvim-builtin<CR>
  nnoremap <silent> <leader><CR> :below terminal<CR><ScriptCmd>misc#SetTerminalOptions()<CR>
  nnoremap <silent> <C-z>
    \ :below terminal ++close ++norestore
    \ /bin/sh -c "tmux -L gvim-terminal new-session -c $HOME -A -D -s gvim-terminal"<CR><ScriptCmd>misc#SetTerminalOptions()<CR>
else
  nnoremap <silent> <leader><CR>
    \ :below terminal ++close ++norestore
    \ /bin/sh -c "tmux -L vim-terminal new-session -c $HOME -A -D -s vim-terminal"<CR><ScriptCmd>misc#SetTerminalOptions()<CR>
endif
nnoremap <silent> <leader><C-z> :terminal ++curwin ++noclose<CR><ScriptCmd>misc#SetTerminalOptions()<CR>
# *avoid* to use <ESC> mappings in terminal mode
# tnoremap <C-[> <C-w>N
# tnoremap <expr> <C-[> (&ft == "fzf") ? "<ESC>" : "<C-w>N"
tnoremap <C-w><Esc> <C-w>N:doautocmd CmdwinLeave<CR>
tnoremap <C-d> <C-w>:bd!<CR>

# move
nnoremap <leader><C-j> :move .+1<CR>==
nnoremap <leader><C-k> :move .-2<CR>==
inoremap <leader><C-j> <C-\><C-n>:move .+1<CR>==gi
inoremap <leader><C-k> <C-\><C-n>:move .-2<CR>==gi
vnoremap <leader><C-j> :move '>+1<CR>gv=gv
vnoremap <leader><C-k> :move '<-2<CR>gv=gv

# automatic close of chars
# see autoclosechars plugin
# inoremap ' ''<left>
# inoremap " ""<left>
# inoremap ( ()<left>
# inoremap [ []<left>
# inoremap { {}<left>
# inoremap {<CR> {<CR>}<C-\><C-o>O

# tabs
nnoremap <leader>, :tabprevious<CR>
nnoremap <leader>. :tabnext<CR>

# buffers
# nnoremap <leader>n :bnext<CR>
nnoremap <leader><C-n> :bnext<CR>
# nnoremap <leader>p :bprev<CR>
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
nnoremap <leader>bK <ScriptCmd>misc#BufferKill()<CR>
# see N<C-^>
# go to N buffer (up to 9 for now)
# for i in range(1, 9)
#   if i <= 9 && g:misc_enabled
#     execute "nnoremap <leader>b" .. i .. " <ScriptCmd>misc#GoBufferPos(" .. i .. ")<CR>"
#    endif
# endfor
if g:misc_enabled
  command! Bk :MiscBufferKill
endif

# see :oldfiles, :browse oldfiles
nnoremap <leader>of :CycleOldFiles<CR>
command! History :CycleOldFiles

# quickfix/location list
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprev<CR>
nnoremap <leader>cj :cnfile<CR>
nnoremap <leader>ck :cpfile<CR>
nnoremap <leader>co :copen<CR>
nnoremap <leader>lo :lopen<CR>
nnoremap <leader>cc :cclose<CR>
nnoremap <leader>lc :lclose<CR>
nnoremap <leader>pc :pclose<CR>
nnoremap <leader>pC :pclose<CR>:cclose<CR>
nnoremap <leader>cl :clist<CR>
nnoremap <leader>cf :cfirst<CR>
nnoremap <leader>ce :clast<CR>
nnoremap <leader>cx <ScriptCmd>setqflist([], 'r') <bar> cclose<CR>
nnoremap <leader>lx <ScriptCmd>setloclist(0, [], 'r') <bar> lclose<CR>

# popup window
nnoremap <leader>cP <ScriptCmd>popup_clear(1)<CR>

# case sensitive/insensitive
nnoremap <leader>ss /\C
nnoremap <leader>si /\c

# diff (see copy-diff)
if g:misc_enabled
  nnoremap <localleader>dt <ScriptCmd>misc#DiffToggle()<CR>:echo v:statusmsg<CR>
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
# nnoremap <leader><C-j> :resize +5<CR>
# nnoremap <leader><C-k> :resize -5<CR>
# nnoremap <leader><C-h> :vertical resize -5<CR>
# nnoremap <leader><C-l> :vertical resize +5<CR>
command! SwapWindow execute "normal! \<C-w>x"

# grep using grepprg + quickfix
command! -nargs=+ -complete=file Grep execute "silent grep! <args>" | cwindow | redraw!
command! -nargs=+ -complete=file Grepi {
  var grepprg_save = &grepprg
  execute $"set grepprg={substitute(fnameescape(&grepprg), 'smart-case\|case-sensitive', 'ignore-case', '')}"
  execute "silent grep! <args>"
  execute $"set grepprg={fnameescape(grepprg_save)}"
  cwindow
  redraw!
}
command! -nargs=+ -complete=file -bar Grepg searcher#Search(<q-args>, systemlist('git rev-parse --show-toplevel')[0], 'gitprg', 'quickfix')
command! -nargs=+ -complete=file -bar Grepig searcher#Search(<q-args>, '-i', systemlist('git rev-parse --show-toplevel')[0], 'gitprg', 'quickfix')
command! -nargs=+ -complete=file -bar Grepr searcher#Search(<q-args>, systemlist('git rev-parse --show-toplevel')[0], 'grepprg', 'quickfix')
command! -nargs=+ -complete=file -bar Grepir searcher#Search('-i', <q-args>, systemlist('git rev-parse --show-toplevel')[0], 'grepprg', 'quickfix')
# vimgrep + quickfix
command! -nargs=+ -complete=file Vimgrep execute "silent vimgrep! <args>" | cwindow | redraw!
nnoremap <leader>/ mS:Vimgrep<Space>//gj<Space><C-r>=fnamemodify(expand('%'), ':~')<CR><C-b><S-Right><Right><Right>

# find using searcher plugin
if g:searcher_enabled
  command! -nargs=+ -complete=file -bar Find searcher#Search(<q-args>, '-p', getcwd(), 'findprg', 'quickfix')
  command! -nargs=+ -complete=file -bar Findr searcher#Search(<q-args>, '-p', systemlist('git rev-parse --show-toplevel')[0], 'findprg', 'quickfix')
  command! -nargs=+ -complete=file -bar Findi searcher#Search('-i', <q-args>, '-p', getcwd(), 'findprg', 'quickfix')
  command! -nargs=+ -complete=file -bar Findir searcher#Search('-i', <q-args>, '-p', systemlist('git rev-parse --show-toplevel')[0], 'findprg', 'quickfix')
  command! -nargs=1 -complete=dir FindDir searcher#Popup('find', '<args>')
  command! -nargs=1 -complete=dir GrepDir searcher#Popup('grep', '<args>')
endif
def FindPrg(arg: string, _): list<string>
  var fuzzy = get(b:, 'findfunc_fuzzy_enabled', false)
  var fuzzyOpts = get(b:, 'findfunc_fuzzy_opts', {})
  var exclude = [
    '--exclude', '.git',
    '--exclude', '.cache',
    '--exclude', '.idea',
    '--exclude', '.venv',
    '--exclude', 'node_modules',
    '--exclude', '/backups',
    '--exclude', '/undodir'
  ]
  var cmd = $'fd --type f --follow --color=never --unrestricted {join(exclude)}'
  var files = systemlist(cmd)
  var out: list<string> = []
  if empty(arg)
    out = files
  elseif fuzzy
    out = matchfuzzy(files, arg, fuzzyOpts)
  else
    out = filter(files, $"v:val =~? '{arg}'")
  endif
  return out
enddef
# :find with a function
b:findfunc_fuzzy_enabled = false
b:findfunc_fuzzy_opts = {limit: 200, smartcase: true}
setglobal findfunc=FindPrg

# edit file in the same directory as the current file
nnoremap <leader>ee :e <C-r>=fnamemodify(expand('%:p:h'), ':~') .. '/'<CR>
# command! -nargs=1 -complete=customlist,misc#CompleteSameDir Ee e <args>
# cnoremap E e <C-r>=fnamemodify(expand('%:p:h'), ':~') .. '/'<CR>
cabbrev E e <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>
cabbrev Sp sp <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>
cabbrev Vs vsp <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>
cabbrev Tabe tabe <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>

# open Se in the same directory as the current file
nnoremap <leader>dd :Se <C-r>=fnamemodify(expand('%:p:h'), ':~') .. '/'<CR>
cabbrev D Se <C-r>=fnamemodify(expand('%:p:h'), ':~')<CR><C-r>=utils#Eatchar('\s') .. '/'<CR>

# change to directory of the current file
nnoremap <silent> <leader>cd :LCDC<CR>
nnoremap <silent> <leader>cD :CDC<CR>
command! CDC cd %:p:h
command! LCDC lcd %:p:h

# plan9 theme
def Plan9(style: string)
  g:plan9_style = style
  g:loaded_plan9 = false
  set background=light
  colorscheme plan9
enddef
command! Plan9 Plan9(get(g:, "plan9_style", "light"))

# darkula theme
def Darkula(style: string)
  g:darkula_style = style
  g:loaded_darkula = false
  set background=dark
  colorscheme darkula
enddef
command! Darkula Darkula(get(g:, "darkula_style", "dark"))
command! DarkulaLight Darkula("light")
command! DarkulaDark Darkula("dark")
command! DarkulaToggleCursor g:darkula_cursor2 = !g:darkula_cursor2 | Darkula

# reload the current theme
command! ReloadTheme {
  if g:colors_name == "plan9"
    Plan9(g:plan9_style)
  elseif g:colors_name == "darkula"
    Darkula(g:darkula_style)
  else
    silent execute $"colorscheme {g:colors_name}"
  endif
}

# reload vimrc
command! ReloadVimrc {
  g:loaded_vimrc = false
  source $MYVIMRC
  if &filetype != ''
    execute 'ReloadFileType'
  endif
}

# reload vimrc local
command! ReloadVimrcLocal {
  if filereadable(vimrc_local)
    g:loaded_vimrc_local = false
    execute $"source {vimrc_local}"
  endif
}

# reload filetype
command! ReloadFileType doautocmd <nomodeline> FileType

# reload syntax
command! ReloadSyntax {
  var wid = win_getid()
  windo doautocmd <nomodeline> Syntax
  win_gotoid(wid)
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
if has('gui_running')
  command! SetGuiFont set guifont=*
  command! Fonti misc#FontSize("increase")
  command! Fontd misc#FontSize("decrease")
  command! Fontr misc#FontSize("reset")
  noremap <leader>+ <ScriptCmd>misc#FontSize("increase")<CR>
  noremap <leader>- <ScriptCmd>misc#FontSize("decrease")<CR>
  noremap <leader>= <ScriptCmd>misc#FontSize("reset")<CR>
endif

# nosmartcase for wildmenu
# augroup event_cmdsmartcase
#     autocmd!
#     autocmd CmdLineEnter : setlocal nosmartcase
#     autocmd CmdLineLeave : setlocal smartcase
# augroup END

# vim events
augroup event_vim
  autocmd!
  # save the session and the view
  autocmd VimLeavePre * ++once {
    if isdirectory(sessiondir)
      # var session = fnamemodify(v:this_session, ':t:r')
      # if !empty(session) && session != "last"
      #   execute $"mksession! {sessiondir}/{session}.vim"
      # endif
      execute $"mksession! {sessiondir}/last.vim"
    endif
    if isdirectory(&viewdir)
      execute $"mkview! {&viewdir}/last.vim"
    endif
  }
  # reset the cursor shape and redraw the screen
  # autocmd VimEnter * ++once startinsert | stopinsert | redraw!
  # clear the terminal on exit
  autocmd VimLeave * ++once {
    if !has('gui_running')
      if xterm
        silent !printf '\e[0m'
      elseif st || st_tmux
        # 2: block cursor "█"
        silent !printf "\e[2 q"
      # elseif alacritty_tmux
      #   if index(systemlist("tmux display-message -p '#S'"), "scratchpad") != -1
      #     silent !printf "\e[4 q"
      #   endif
      # endif
      endif
    endif
  }
augroup END

# load local config
if filereadable(vimrc_local)
  execute $"source {vimrc_local}"
endif

# set theme
if !exists('g:colors_name')
  execute $"set background={background}"
  execute $"colorscheme {colortheme}"
endif

# compile functions
defcompile
