" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:loaded_vimrc') && g:loaded_vimrc == 1
  echohl WarningMsg
  echom "Warning: file vimrc is already loaded"
  echo ":let g:loaded_vimrc = 0 (to unblock it)"
  echohl None
  finish
endif
if has("eval")
  let g:loaded_vimrc = 1  " already loaded
  let s:eval = 1          " +eval (not enabled in vim tiny/small versions)
endif

" config variables
if s:eval
  let s:colorscheme = "plan9"                                                                 " theme
  let s:background = "light"                                                                  " background
  let s:hostname = hostname()                                                                 " hostname
  let s:mac = has('mac')                                                                      " mac
  let s:gui = has('gui_running')                                                              " gui
  let s:macvim = has('gui_macvim')                                                            " macvim
  let s:tmux = !empty($TMUX) || &term =~# "tmux"                                              " tmux
  let s:screen = (!empty($STY) || &term =~# "screen") && !s:tmux                              " screen
  let s:multiplexer = s:screen || s:tmux                                                      " multiplexer
  " let s:vim_terminal = !empty($VIM_TERMINAL)                                                " vim terminal mode
  let s:xterm = !empty($XTERM_VERSION) && !s:multiplexer                                      " xterm
  let s:xterm_screen = !empty($SCREEN_PARENT_XTERM_VERSION) && s:screen                       " xterm + screen
  let s:xterm_tmux = !empty($TMUX_PARENT_XTERM_VERSION) && s:tmux                             " xterm + tmux
  let s:apple_terminal = $TERM_PROGRAM ==# "Apple_Terminal" && !s:multiplexer                 " terminal.app
  let s:apple_terminal_screen = $SCREEN_PARENT_TERM_PROGRAM ==# "Apple_Terminal" && s:screen  " terminal.app + screen
  let s:apple_terminal_tmux = $TMUX_PARENT_TERM_PROGRAM ==# "Apple_Terminal" && s:tmux        " terminal.app + tmux
  let s:alacritty = &term =~# "alacritty" && !s:multiplexer                                   " alacritty
  let s:alacritty_screen = $SCREEN_PARENT_TERM =~# "alacritty" && s:screen                    " alacritty + screen
  let s:alacritty_tmux = $TMUX_PARENT_TERM =~# "alacritty" && s:tmux                          " alacritty + tmux
  let s:kitty = &term =~# "xterm-kitty" && !s:multiplexer                                     " kitty
  let s:kitty_screen = $SCREEN_PARENT_TERM =~# "xterm-kitty" && s:screen                      " kitty + screen
  let s:kitty_tmux = $TMUX_PARENT_TERM =~# "xterm-kitty" && s:tmux                            " kitty + tmux
endif

" don't load defaults.vim
if s:eval
  let g:skip_defaults_vim = 1
endif

" disable some default plugins
if s:eval
  let g:loaded_2html_plugin = 1      " tohtml.vim
  let g:loaded_getscriptPlugin = 1   " getscriptPlugin.vim
  let g:loaded_gzip = 1              " gzip.vim
  let g:loaded_logiPath = 1          " logiPat.vim
  let g:loaded_matchparen = 1        " matchparen.vim
  let g:loaded_netrwPlugin = 1       " netrwPlugin.vim
  let g:loaded_rrhelper = 1          " rrhelper.vim
  let g:loaded_spellfile_plugin = 1  " spellfile.vim
  let g:loaded_tar = 1               " pi_tar
  let g:loaded_tarPlugin = 1         " tarPlugin.vim
  let g:loaded_vimballPlugin = 1     " vimballPlugin.vim
  let g:loaded_zip = 1               " zip.vim
  let g:loaded_zipPlugin = 1         " zipPlugin.vim
endif

" enable custom plugins
if s:eval
  let g:checker_enabled = 1  " checker plugin
  let g:se_enabled = 1       " se plugin (simple explorer)
endif

" set shell $PATH for MacVim if it is lauched without using a terminal
if s:macvim && empty($TERM)
  let $PATH = $HOME."/bin:".$HOME."/opt/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/opt/local/sbin:/opt/local/bin:".$HOME."/opt/go/bin:".$HOME."/opt/aws/bin"
endif

" set python3 version with dynamic loading support
if has("python3_dynamic")
  if s:mac
    let s:pyver = "3.8"
    let s:homepython ="/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/".s:pyver
    let s:libpython = s:homepython."/lib/python".s:pyver."/config-".s:pyver."-darwin/libpython".s:pyver.".dylib"
  else
    let s:pyver = "3.9"
    let s:homepython ="/usr"
    let s:libpython ="/usr/lib/x86_64-linux-gnu/libpython".s:pyver.".so.1"
  endif
  if isdirectory(s:homepython) && filereadable(s:libpython)
    execute "set pythonthreehome=".s:homepython
    execute "set pythonthreedll=".s:libpython
  endif
endif

" global settings
set nocompatible    " use vim defaults instead of 100% vi compatibility
set shortmess=a     " abbreviation status messages shorter (default filnxtToOS)
set shortmess+=I    " no vim splash
set shortmess+=c    " don't give ins-completion-menu messages
set cmdheight=1     " space for displaying status messages (default is 1)
set noerrorbells    " turn off error bells (do not bell on errors)
set belloff=all     " turn off error bells (do not bell on all events)
set novisualbell    " turn off visual bell (no sound, no visuals)
set title           " update title window (dwm top bar)
set titlestring=%F  " when non-empty, sets the title of the window. it uses statusline syntax (default empty)
set titleold=       " do not show default title "thanks for flying vim" if set notitle
set noicon          " the icon text of the window will not be set to the value of iconstring
set noallowrevins   " allow ctrl-_ in insert and cwmmand-line mode (default is off)
set showmode        " show current mode insert, command, replace, visual, etc
set showcmd         " show command on the last line of screen (ex: see visual mode)
set esckeys         " allow usage of cursor keys within insert mode
set lazyredraw      " on: redraw only when needed, nice for editing macros
set linespace=0     " number of pixel lines inserted between characters (default is 0)
set autoread        " automatically read the file if it has been modified externally
" set autowrite     " write automatically the contents of the file if it has been modified (:make, <C-]> etc.)

" vim
if !s:gui
  " viminfo with vim version
  execute "set viminfofile=".$HOME."/.viminfo_".v:version

  " cursor shapes
  " &t_SI = blinking vertical bar (INSERT MODE)
  " &t_SR = blinking underscore   (REPLACE MODE)
  " &t_EI = blinking block        (NORMAL MODE)
  if s:mac && (s:apple_terminal || s:apple_terminal_screen || s:apple_terminal_tmux
  \ || s:alacritty || s:alacritty_screen || s:alacritty_tmux
  \ || s:kitty || s:kitty_screen || s:kitty_tmux)
    let &t_SI.="\eP\e[5 q\e\\"
    let &t_SR.="\eP\e[3 q\e\\"
    let &t_EI.="\eP\e[1 q\e\\"
  elseif s:xterm || s:xterm_screen || s:xterm_tmux
    let &t_SI.="\eP\e[6 q\e\\"
    let &t_SR.="\eP\e[4 q\e\\"
    let &t_EI.="\eP\e[2 q\e\\"
  endif

  " screen/tmux/alacritty mouse codes
  if match(&term, '^\(screen\|tmux\|alacritty\)') != -1
    if s:eval
      let s:code_ttymouse = s:mac ? "sgr" : "xterm2"
      execute "set ttymouse=" . s:code_ttymouse
    endif
  endif

  " automatically is on when term is xterm/screen (fast terminal)
  if match(&term, '^\(xterm\|screen\|tmux\|alacritty\)') != -1
    set ttyfast
  endif

  " italic fonts support
  if (s:xterm || s:apple_terminal) && !s:multiplexer
    let &t_ZH="\e[3m"
    let &t_ZR="\e[23m"
  endif

  " 24-bit terminal color
  if has('termguicolors') && &t_Co >= 256
    if (s:xterm || s:xterm_tmux || s:alacritty || s:alacritty_tmux || s:kitty || s:kitty_tmux) && !s:screen
      " :help xterm-true-color
      let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
      let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
      set termguicolors
    else
      set notermguicolors
    endif
  endif
endif

" gui
if s:gui
  if s:macvim
    " viminfo with macvim version
    execute "set viminfofile=".$HOME."/.viminfo_macvim_".v:version
    let s:gui_fontsize = s:hostname ==# "aiur" ? 14 : 16
    execute "set guifont=Menlo\\ Regular:h" . s:gui_fontsize
    set antialias                          " smooth fonts
  else
    " viminfo with vim version (same as non-gui)
    execute "set viminfofile=".$HOME."/.viminfo_".v:version
    set guifont=DejaVu\ Sans\ Mono\ 12     " gui font
  endif
  set guioptions=acM               " do not load menus for gui (default aegimrLtT)
  set guiheadroom=0                " when zero, the whole screen height will be used by the window
  set mouseshape-=v:rightup-arrow  " by default uses a left arrow that confuses
  set mouseshape+=v:beam           " change it by beam shape (as in other apps)
  set mousehide                    " hide the mouse pointer while typing (default on)
endif

" see :filetype
if has("autocmd")
  filetype on
  filetype plugin on
  filetype indent on
endif

" enable syntax rules (needs to be after filetype plugin)
if has("syntax")
  syntax on
endif

" global settings
set ruler                    " show line & column number
set magic                    " use extended regexp in search patterns
set modelines=0              " do not use modelines
set nomodeline               " avoid modeline vulnerability
set equalalways              " windows are automatically made the same size after splitting or closing a window
set helpheight=0             " zero disables this (default 20)
set formatoptions-=cro       " remove '"' line below automatically when current line is a comment (after/ftplugin/vim.vim)
set formatoptions+=j         " delete comment character when joining commented lines (:help fo-table) (default is tcq)
set nrformats-=octal         " do not recognize octal numbers for Ctrl-A and Ctrl-X
set scrolloff=5              " minimal number of screen lines to keep above and below the cursor (default is 5)
set sidescrolloff=5          " minimal number of screen columns to keep to the left and to the right of the cursor
set nostartofline            " some jump commands move the cursor to the first non-blank like <C-^> previous buffer
set nojoinspaces             " disable adding to spaces after '.' when joining a file, adding one instead of two
set nofixeol                 " do not add an EOL at the end of file if missing, keep original file as is (default on)
set notimeout                " don't time out on :mappings
set ttimeout ttimeoutlen=10  " time out for key codes (default 100ms ESC etc)
set keymodel=startsel        " using a shifted special key starts (<S-Left,Right,Up,Down>) (visual or select mode)
set keymodel+=stopsel        " using non shifted stops (visual or select mode)
set cpoptions-=aA            " don't set '#' alterative file for :read and :write
set laststatus=2             " to display the status line always
set display=lastline         " the last line in a window will be displayed if possible
set ignorecase               " case-insensitive search (also affects if == 'var', use if ==# 'var')
set smartcase                " except if start with capital letter
set tagcase=followscs        " default followic, (followscs follow the 'smartcase' and 'ignorecase' options)
set hlsearch                 " to highlight all search matches
set incsearch                " jumps to search word when typing on serch /foo (default no)
set wrap                     " wrap is also enabled by default
set nospell                  " disable spell checking
set noshowmatch              " disable matching parenthesis
set matchtime=1              " seconds to show matching parenthesis
set matchpairs=(:),{:},[:]   " characters that form pairs
set nofoldenable             " when off, all folds are open
set foldmethod=manual        " disable automatic folding
set cursorline               " mark with another color the current cursor line
set path+=**                 " set path for finding files with :find
set t_ut=                    " disable background color erase (BCE)
" set t_ti= t_te=            " do not restore screen contents when exiting Vim (see: help norestorescreen / xterm alternate screen)

" default shell
if !empty($SHELL)&& executable($SHELL)
  set shell=$SHELL
elseif executable("/bin/bash")
  set shell=/bin/bash
else
  set shell=/bin/sh
endif

" behavior of cursorline {line, number} (default both)
if exists('+cursorlineopt')
  set cursorlineopt=both
endif

" mouse support
if has('mouse')
  set mouse=a
endif

" prevents that the langmap option applies to characters (from defaults.vim)
if has("langmap") && exists("+langremap")
  set nolangremap
endif

" wildmenu
if has("wildmenu")
  set wildmenu               " enchange command line completion
  set wildmode=longest,full  " default
  if has("patch-8.2.4325")
    set wildoptions=pum      " (pum) the completion matches are shown in a popup menu
  endif
endif

" statusline
if s:eval
  let g:statusline_base = &statusline
endif
set showtabline=1          " to show tab only if there are at least two tabs (2 to show tab always) (default 1)
set tabline=%!MyTabLine()  " my custom tabline (see :help setting-tabline)
set statusline=%<%F\ %h%m%r%=%{&filetype}\ %{&fileencoding}[%{&fileformat}]\ %{MyStatusLine()}\ %-14.(%l,%c%V%)\ %P

" utf-8 support
if has("multi_byte")
  set encoding=utf-8      " encoding displayed
  set fileencoding=utf-8  " encoding written to file
endif

" show special characters (listchars must be after enconding configuration)
set nolist
if &encoding ==# "utf-8"
  set listchars=tab:»·,trail:¨
endif

" vertical seperator for vertical split windows
set fillchars=vert:\ ,fold:-  " contains one space!

" more powerful backspacing
set backspace=indent,eol,start

" tabs/spaces
set tabstop=2      " number of spaces a <tab> in the text stands for
set softtabstop=2  " if non-zero, number of spaces to insert for a <tab>
set shiftwidth=2   " number of spaces used for each step of (auto)indent
set shiftround     " round to shiftwidth for "<<" and ">>"
set expandtab      " expand <tab> to spaces in insert mode

" backup files
set backup
set writebackup
set backupcopy=auto
set backupdir=$HOME/.vim/backups
set directory=$HOME/.vim/tmp//  "// use absolute path

" :help undo-persistence
if has('persistent_undo')
  set undofile                    " automatically save your undo history when you write a file 
  set undolevels=1000             " default is 1000
  set undodir=$HOME/.vim/undodir  " directory to store undo files
endif

" history of commands and previous search patterns (default is 200)
set history=200

" mksession options
if has('mksession')
  set sessionoptions-=options
  set sessionoptions-=localoptions
  set sessionoptions-=folds
  set sessionoptions+=resize,winpos
endif

" views options
set viewoptions-=options
set viewoptions-=localoptions
set viewoptions-=folds

" buffers
set hidden    " buffer becomes hidden when it is abandoned
set report=0  " show always the number of lines changed (default 2)
set confirm   " use dialog confirmation before exiting if files have not been saved
set more      " when on, listings pause when the whole screen is filled (default on)

" indent
set autoindent      " copy indent from current line when starting a new line 
set copyindent      " copy the structure of the existing lines indent when autoindenting a new line
set preserveindent  " when changing the indent of the current line, preserve it if possible
" set smartindent   " clever autoindenting, works for C-like programs (see cinwords)

" :help ins-completion
" <C-x><C-o>
set omnifunc=syntaxcomplete#Complete
" <C-x><C-u>
set completefunc=syntaxcomplete#Complete

" completion
if has('popupwin')
  set completeopt=menuone,noinsert,popup  " popup extra info, like using omnicompletion
else
  set completeopt=menuone,noinsert
endif
if exists('+completepopup')
  set completepopup+=highlight:InfoPopup  " see InfoPopUp in theme
endif
" .: the current buffer
" w: buffers in other windows
" b: other loaded buffers
" u: unloaded buffers
" k: dictionary files with dictionary option
" t: tags
set complete=.,w,b,u,k,t

" (empty) default vim clipboard
" * X11 primary clipboard (mouse middle button)
" + standard clipboard (firefox <C-c> <C-v>)
"
"                         YANK          delete,put,change    delete,put,change one line or more
" (empty)               "", "0             "", "-              "", "1
" unnamed               "", "0, "*         "", "-, "*          "", "1, "*
" unnamedplus           "", "0, "+         "", "-, "+          "", "1, "+
" unnamed,unnamedplus   "", "0, "*, "+     "", "-, "+          "", "1, "+

" use clipboard register '+' and also copies it to '*' (yank only)
if has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif

" signs
if has("signs")
  " draw only the sign column if contains signs
  if has("patch-8.1.1564")
    set signcolumn=number
  else
    set signcolumn=auto
  endif

  " sh
  sign define sh_error text=✘ texthl=SyntaxErrorSH
  sign define sh_errorplus text=↪+ texthl=SyntaxErrorPlus
  sign define sh_shellcheckerror text=↪ texthl=SyntaxErrorSHELLCHECK

  " python
  sign define py_error text=✘ texthl=SyntaxErrorPY
  sign define py_errorplus text=↪+ texthl=SyntaxErrorPlus
  sign define py_pep8error text=↪ texthl=SyntaxErrorPEP8

  " go
  sign define go_error text=✘ texthl=SyntaxErrorGO
  sign define go_errorplus text=↪+ texthl=SyntaxErrorPlus
  sign define go_veterror text=↪ texthl=SyntaxErrorGOVET
endif

" key mapping
"---------------------------------------------------------------------------"
" Commands / Modes | Normal | Insert | Command | Visual | Select | Operator |
"------------------|--------|--------|---------|--------|--------|----------|
" map  / noremap   |    x   |   -    |    -    |   x    |   x    |    x     |
" nmap / nnoremap  |    x   |   -    |    -    |   -    |   -    |    -     |
" vmap / vnoremap  |    -   |   -    |    -    |   x    |   x    |    -     |
" omap / onoremap  |    -   |   -    |    -    |   -    |   -    |    x     |
" xmap / xnoremap  |    -   |   -    |    -    |   x    |   -    |    -     |
" smap / snoremap  |    -   |   -    |    -    |   -    |   x    |    -     |
" map! / noremap!  |    -   |   x    |    x    |   -    |   -    |    -     |
" imap / inoremap  |    -   |   x    |    -    |   -    |   -    |    -     |
" cmap / cnoremap  |    -   |   -    |    x    |   -    |   -    |    -     |
"---------------------------------------------------------------------------"

" macOS default Terminal.app
" :help mac-lack
" <C-^> needs to be entered as <C-S-6>
" <C-@> needs to be entered as <C-S-2>

" mapping leaders
if s:eval
  " mapleader
  let mapleader = "\<C-s>"

  " alternative second leader
  let maplocalleader = "\<C-\>"
endif


" the key that starts a <C-w> command in a terminal mode
set termwinkey=<C-s>

" disable arrow keys
" call DisableArrowKeys()

" se plugin (simple explorer)
if get(g:, "se_enabled")
  nnoremap <leader>ex :call SeToggle()<CR>
  command! SeToggle :call SeToggle()
endif

" save
nnoremap <leader><C-w> :update<CR>
inoremap <leader><C-w> <C-o>:update<CR>

" edit
nnoremap <leader>ev :e $HOME/.vimrc<CR>
nnoremap <leader>ef :e $HOME/.vim/plugin/functions.vim<CR>
nnoremap <leader>et :e $HOME/.vim/colors/plan9.vim<CR>
nnoremap <leader>ee :e **/*
nnoremap <leader>eb :browse oldfiles<CR>

" source
nnoremap <leader>sv :source $HOME/.vimrc<CR>
nnoremap <leader>sV :let g:loaded_vimrc=0<CR>:source $HOME/.vimrc<CR>
nnoremap <leader>st :let g:loaded_plan9=0<CR>:colorscheme plan9<CR>
nnoremap <leader>sf :let g:loaded_functions=0<CR>:source $HOME/.vim/plugin/functions.vim<CR>
nnoremap <leader>sa :let g:loaded_vimrc=0<CR>:source $HOME/.vim/vimrc<CR>
                   \:let g:loaded_functions=0<CR>:source $HOME/.vim/plugin/functions.vim<CR>
                   \:let g:loaded_checker=0<CR>:source $HOME/.vim/plugin/checker/checker.vim<CR>
                   \:let g:loaded_se=0<CR>:source $HOME/.vim/plugin/se/se.vim<CR>

" toggle
nnoremap <leader>tgn :setlocal number! number? \| echon " (setlocal)"<CR>
nnoremap <leader>tgN :set number! number? \| echon " (set)"<CR>
nnoremap <leader>tgr :setlocal relativenumber! relativenumber? \| echon " (setlocal)"<CR>
nnoremap <leader>tgR :set relativenumber! relativenumber? \| echon " (set)"<CR>
nnoremap <leader>tgj :setlocal joinspaces! joinspaces? \| echon " (setlocal)"<CR>
nnoremap <leader>tgJ :set joinspaces! joinspaces? \| echon " (set)"<CR>
nnoremap <leader>tgl :setlocal list! list?<CR>
nnoremap <leader>tgh :setlocal hlsearch! hlsearch?<CR>
nnoremap <leader>tgp :setlocal paste! paste?<CR>
nnoremap <leader>tgd :call DiffToggle()<CR>
nnoremap <leader>* :nohlsearch<CR>
nnoremap <silent><leader>tgs :call SyntaxToggle()<CR>:redraw!<CR>:echo v:statusmsg<CR>
nnoremap <leader>tgb :call BackgroundToggle()<CR>:redraw!<CR>:echo v:statusmsg<CR>

" sign, fold
nnoremap <leader>tgc :call SignColumnToggle()<CR>
nnoremap <leader>tgf :call FoldColumnToggle()<CR>
nnoremap <leader>tgz :call FoldToggle()<CR>

" :sh
if s:gui
  nnoremap <leader>sh :call SH()<CR>
  command! SH :call SH()
else
  nnoremap <leader>sh :sh<CR>
endif

" run
nnoremap <leader>ru :call Run()<CR>
command! Run :call Run()
nnoremap <leader>rU :call RunInWindow()<CR>
command! RunWindow :call RunInWindow()
nnoremap <leader>fm :call FormatLanguage()<CR>
command! FormatLanguage :call FormatLanguage()
nnoremap <leader>; mt<ESC>$a;<ESC>`t
nnoremap <silent><leader><CR> :below terminal<CR>
if s:gui
  nnoremap <silent><leader><C-CR> :below terminal<CR>
endif
nnoremap <silent><leader>z :terminal ++curwin ++noclose<CR>
nnoremap <silent><leader><C-z> :terminal ++curwin ++noclose<CR>

" move
nnoremap <leader><C-d> :move .+1<CR>==
nnoremap <leader><C-u> :move .-2<CR>==
inoremap <leader><C-d> <Esc>:move .+1<CR>==gi
inoremap <leader><C-u> <Esc>:move .-2<CR>==gi
vnoremap <leader><C-d> :move '>+1<CR>gv=gv
vnoremap <leader><C-u> :move '<-2<CR>gv=gv

" gui
if s:gui
  map <S-Insert> <Nop>
  map! <S-Insert> <MiddleMouse>
  nnoremap <leader><S-F10> :call GuiMenuBarToggle()<CR>:echo v:statusmsg<CR>
  command! GuiMenuBarToggle :call GuiMenuBarToggle()
endif
nnoremap <leader>, :tabprevious<CR>
nnoremap <leader>. :tabnext<CR>
" * avoid to use <Esc> mappings in terminal mode
" tnoremap <C-[> <C-w>N
" tnoremap <expr> <C-[> (&ft ==# "fzf") ? "<Esc>" : "<C-w>N"

" buffers
nnoremap <leader>n :bnext<CR>
nnoremap <leader><C-n> :bnext<CR>
nnoremap <leader>p :bprev<CR>
nnoremap <leader><C-p> :bprev<CR>
nnoremap <leader><leader> :b #<CR>
nnoremap <leader><Space> :call CycleBuffers()<CR>
nnoremap <leader><C-g> 2<C-g>
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bD :bd!<CR>
nnoremap <leader>bw :bw<CR>
nnoremap <leader>bW :bw!<CR>
nnoremap <leader>ba :ball<CR>
nnoremap <leader>bs :sall<CR>
nnoremap <leader>bv :vertical ball<CR>
nnoremap <leader>bo :call BufferRemoveAllExceptCurrent('delete')<CR>
nnoremap <leader>bO :call BufferRemoveAllExceptCurrent('wipe')<CR>
nnoremap <leader>bf :bfirst<CR>
nnoremap <leader>bl :blast<CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>
nnoremap <leader>bj :bnext<CR>:redraw!<CR>:ls<CR>
nnoremap <leader>bk :bprev<CR>:redraw!<CR>:ls<CR>
" if s:eval
"   " go to N buffer (up to 9 for now)
"   for s:i in range(1, 9)
"     if s:i <= 9
"       execute "nnoremap <leader>b".s:i." :call GoBufferPos(".s:i.")<CR>"
"     endif
"   endfor
" endif

" all buffers except the current one
command! BufferDeleteListedExceptCurrent :call BufferRemoveAllExceptCurrent('delete')
command! BufferWipeListedExceptCurrent :call BufferRemoveAllExceptCurrent('wipe')
command! BufferWipeAllExceptCurrent :call BufferRemoveAllExceptCurrent('wipe!')

" quickfix
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
nnoremap <leader>cx :call setqflist([], 'r')<CR>
nnoremap <leader>lx :call setloclist(0, [], 'r')<CR>

" popup window
nnoremap <leader>cP :call popup_clear(1)<CR>

" comment/uncomment by language
nnoremap <leader>/ :call CommentByLanguage()<CR>
nnoremap <leader>? :call UncommentByLanguage()<CR>
vnoremap <leader>* <ESC>'<<ESC>O/*<ESC>'><ESC>o*/<ESC>
vnoremap <leader>/ <ESC>:'<,'>s/^/\/\/ /e<ESC>
vnoremap <leader>? <ESC>:'<,'>s/\/\///g<ESC>gv=

" case sensitive/insensitive
nnoremap <leader>ss /\C
nnoremap <leader>si /\c
nnoremap <leader>sl :call MenuLanguageSpell()<CR>

" diff original file with unwritted changes
nnoremap <silent><localleader>dt :call DiffToggle()<CR>
nnoremap <localleader>de :diffthis<CR>
nnoremap <localleader>dw :window diffthis<CR>
nnoremap <localleader>dd :diffoff<CR>
nnoremap <localleader>dD :diffoff!<CR>
nnoremap <localleader>= :1,$+1diffget<CR>
nnoremap <localleader>, :.,.diffget<CR>
nnoremap <localleader>. :.,.diffput<CR>
nnoremap <localleader>/ :diffupdate<CR>

" diff
command! DiffGetAll :1,$+1diffget
command! DiffPutAll :1,$+1diffput
command! DiffGetLine :.,.diffget
command! DiffPutLine :.,.diffput
" from defaults.vim
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
endif

" windows
nnoremap <leader>cw :close<CR>
nnoremap <leader>ch :helpclose<CR>
nnoremap <leader>ct :tabclose<CR>
command! SwapWindow :execute "normal! \<C-w>x"
nnoremap <leader><C-j> :resize +5<CR>
nnoremap <leader><C-k> :resize -5<CR>
nnoremap <leader><C-h> :vertical resize -5<CR>
nnoremap <leader><C-l> :vertical resize +5<CR>

" scratch buffer
nnoremap <silent><leader>s<BS> :call ScratchBuffer()<CR>
nnoremap <silent><leader>s<CR> :call ScratchTerminal()<CR>
nnoremap <silent><leader>sc :call ScratchBuffer()<CR>
nnoremap <silent><leader>sz :call ScratchTerminal()<CR>
command! ScratchBuffer :call ScratchBuffer()
command! ScratchTerminal :call ScratchTerminal()

" menu misc
nnoremap <silent><leader><F10> :call MenuMisc()<CR>
command! MenuMisc :call MenuMisc()

" edit using a top window
command! -nargs=1 Et call EditTop(<f-args>)

" plan9 theme
command! Plan9 :let g:loaded_plan9=0 | set background=light | colorscheme plan9

" vim events
if !s:gui
  augroup event_vim
  autocmd!
  " reset the cursor shape and redraw the screen
  autocmd VimEnter * startinsert | stopinsert | redraw!
  " clear the terminal on exit
  if s:xterm
    autocmd VimLeave * silent !printf '\e[0m'
  endif
  augroup END
endif

" go to last edit cursor position when opening a file
if s:eval
  augroup event_buffer
  autocmd!
  autocmd BufReadPost * call GoLastEditCursorPos()
  augroup END
endif

" load local config
if s:eval
  let s:vimrc_local = $HOME."/.vimrc.local"
  if filereadable(s:vimrc_local)
    execute "source " . s:vimrc_local
  endif
endif

" set theme
if s:eval
  execute "set background=" . s:background
  execute "colorscheme " . s:colorscheme
endif
