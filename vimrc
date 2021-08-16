" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if is already loaded
if exists('g:loaded_vimrc') && g:loaded_vimrc == 1
  echohl WarningMsg
  echom "Warning: file vimrc is already loaded"
  echo ":let g:loaded_vimrc = 0 (to unblock it)"
  echohl None
  finish
endif
let g:loaded_vimrc = 1

" default my plan9 theme
let g:mytheme = "plan9"

" disable some default plugins
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

" set python3 version with dynamic loading support
if has("python3_dynamic")
  " python3.9
  let g:libpython3="/usr/lib/x86_64-linux-gnu/libpython3.9.so.1"
  if filereadable(g:libpython3)
    set pythonthreehome=/usr
    execute "set pythonthreedll=".g:libpython3
  endif
endif

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
set lazyredraw      " redraw only when needed, nice for editing macros
set linespace=0     " number of pixel lines inserted between characters (default is 0)

" vim
if !has("gui_running")
  set ttyfast  " :help ttyfast, fast terminal connection
endif

" gVim
if has("gui_running")
  set guioptions=acM                  " do not load menus for gvim (default aegimrLtT)
  set guiheadroom=0                   " when zero, the whole screen height will be used by the window
  set guifont=DejaVu\ Sans\ Mono\ 12  " gui font
  set mouseshape-=v:rightup-arrow     " by default uses a left arrow that confuses
  set mouseshape+=v:beam              " change it by beam shape (as in other apps)
  set mousehide                       " hide the mouse pointer while typing (default on)
endif

" see :filetype
if has("autocmd")
  filetype on
  filetype plugin on
  filetype indent on
endif

syntax on                    " enable syntax rules (syntax needs to be after filetype plugin)
set ruler                    " show line & column number
set magic                    " use extended regexp in search patterns
set modelines=0              " do not use modelines
set nomodeline               " avoid modeline vulnerability
set shell=/bin/bash          " set bash as default shell
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
set foldlevelstart=99        " don't start new buffers folded (default -1)
set cursorline               " mark with another color the current cursor line
set path+=**                 " set path for finding files with :find

" behavior of cursorline {line, number} (default both)
if exists('+cursorlineopt')
  set cursorlineopt=both
endif

" enable mouse and do not copy numbers if set number exists
if has('mouse')
  set mouse=a
endif

" prevents that the langmap option applies to characters (from defaults.vim)
if has('langmap') && exists('+langremap')
  set nolangremap
endif

" statusline
let g:statusline_base = &statusline
set showtabline=2          " to show tab always
set tabline=%!MyTabLine()  " my custom tabline (see :help setting-tabline)
set statusline=%<%F\ %h%m%r%=%{&filetype}\ %{&fileencoding}[%{&fileformat}]\ %{MyStatusLine()}\ %-14.(%l,%c%V%)\ %P

" show special characters
set nolist
set listchars=tab:»·,trail:¨

" utf-8 support
if has('multi_byte')
  set encoding=utf-8      " utf-8 the encoding displayed
  set fileencoding=utf-8  " utf-8 the encoding written to file
endif

" vertical seperator for vertical split windows
set fillchars=vert:\ ,fold:-  " contains one space!

" more powerful backspacing
set backspace=indent,eol,start

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
set report=0  " show alway the number of lines changed (default 2)
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
if v:version >= 802
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
  set clipboard=unnamed,unnamedplus
endif

" signs

" SH
sign define sh_error text=✘ texthl=SyntaxErrorSH
sign define sh_errorplus text=↪+ texthl=SyntaxErrorPlus
sign define sh_shellcheckerror text=↪ texthl=SyntaxErrorSHELLCHECK

" PY
sign define py_error text=✘ texthl=SyntaxErrorPY
sign define py_errorplus text=↪+ texthl=SyntaxErrorPlus
sign define py_pep8error text=↪ texthl=SyntaxErrorPEP8

" GO
sign define go_error text=✘ texthl=SyntaxErrorGO
sign define go_errorplus text=↪+ texthl=SyntaxErrorPlus
sign define go_veterror text=↪ texthl=SyntaxErrorGOVET

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

" mapleader
let mapleader = "\\"

" alternative second leader
let maplocalleader = "\<C-q>"

" disable arrow keys
" call DisableArrowKeys()

" Se plugin (simple explorer)
nnoremap <leader>ex :call SeToggle()<CR>
command! SeToggle :call SeToggle()

" edit
nnoremap <leader>ev :e $HOME/.vimrc<CR>
nnoremap <leader>ef :e $HOME/.vim/plugin/functions.vim<CR>
nnoremap <leader>et :execute ":e $HOME/.vim/colors/" . g:mytheme . ".vim"<CR>
nnoremap <leader>ee :e **/*
nnoremap <leader>eb :browse oldfiles<CR>

" source
nnoremap <leader>sv :source $HOME/.vimrc<CR>
nnoremap <leader>st :let g:loaded_plan9=0<CR>:execute ":colorscheme " . g:mytheme<CR>
nnoremap <leader>sf :let g:loaded_functions=0<CR>:source $HOME/.vim/plugin/functions.vim<CR>
nnoremap <leader>sa :let g:loaded_vimrc=0<CR>:source $HOME/.vim/vimrc<CR>
                   \:let g:loaded_functions=0<CR>:source $HOME/.vim/plugin/functions.vim<CR>
                   \:let g:loaded_sh=0<CR>:source $HOME/.vim/plugin/sh/sh.vim<CR>
                   \:let g:loaded_py3=0<CR>:source $HOME/.vim/plugin/python/python.vim<CR>
                   \:let g:loaded_py3_functions=0<CR>:source $HOME/.vim/plugin/python/functions.vim<CR>
                   \:let g:loaded_go=0<CR>:source $HOME/.vim/plugin/go/go.vim<CR>
                   \:let g:loaded_go_functions=0<CR>:source $HOME/.vim/plugin/go/functions.vim<CR>
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

" :sh
if has('gui_running')
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
nnoremap <silent><leader>z :below terminal<CR>
nnoremap <silent><leader><C-z> :below terminal<CR>

" move
nnoremap <leader><C-j> :move .+1<CR>==
nnoremap <leader><C-k> :move .-2<CR>==
inoremap <leader><C-j> <Esc>:move .+1<CR>==gi
inoremap <leader><C-k> <Esc>:move .-2<CR>==gi
vnoremap <leader><C-j> :move '>+1<CR>gv=gv
vnoremap <leader><C-k> :move '<-2<CR>gv=gv

" gVim
if has("gui_running")
  map <S-Insert> <Nop>
  map! <S-Insert> <MiddleMouse>
  nnoremap <leader><S-F10> :call GuiMenuBarToggle()<CR>:echo v:statusmsg<CR>
  command! GuiMenuBarToggle :call GuiMenuBarToggle()
endif
nnoremap <leader>, :tabprevious<CR>
nnoremap <leader>. :tabnext<CR>
tnoremap <C-[> <C-w>N

" buffers
nnoremap <leader>n :bnext<CR>
nnoremap <leader><C-n> :bnext<CR>
nnoremap <leader>p :bprev<CR>
nnoremap <leader><C-p> :bprev<CR>
nnoremap <leader><C-g> 2<C-g>
nnoremap <leader><Space> :call CycleBuffers()<CR>
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

" go to N buffer (up to 9 for now)
for i in range(1, 9)
  if i <= 9
    execute "nnoremap <leader>b".i." :call GoBufferPos(".i.")<CR>"
  endif
endfor

" remove all buffers except the current one
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
nnoremap <silent><leader><CR> <C-w>x
command! SwapWindow :execute "normal! \<C-w>x"
" resize horizontal windows
nnoremap <leader><C-i> :resize +5<CR>
nnoremap <leader><C-d> :resize -5<CR>
" resize vertical windows
nnoremap <leader><C-h> :vertical resize -5<CR>
nnoremap <leader><C-l> :vertical resize +5<CR>

" scratch buffer
nnoremap <silent><leader>sc :call ScratchBuffer()<CR>
nnoremap <silent><leader><BS> :call ScratchBuffer()<CR>
command! ScratchBuffer :call ScratchBuffer()

" menu misc
nnoremap <silent><leader><F10> :call MenuMisc()<CR>
command! MenuMisc :call MenuMisc()

" sign, fold
nnoremap <leader>tgc :call SignColumnToggle()<CR>
nnoremap <leader>tgf :call FoldColumnToggle()<CR>
nnoremap <leader>tgz :call FoldToggle()<CR>

" edit using a top window
command! -nargs=1 Et call EditTop(<f-args>)

" plan9 theme
command! Plan9 :let g:loaded_plan9=0 | set background=light | colorscheme plan9

" go to last edit cursor position when opening a file
augroup event_buffer
autocmd!
autocmd BufReadPost * call GoLastEditCursorPos()
augroup END

" set custom theme
if &term =~ "-256color" && !empty($TMUX)
  " disable background color erase (BCE) so schemes can work properly inside tmux
  set t_ut=
endif
if (&term =~ "-256color" || has('gui_running'))
\ && exists("g:mytheme") && g:mytheme ==# "plan9" && !exists("g:loaded_plan9")
  set background=light
  execute "colorscheme " . g:mytheme
elseif !exists("g:loaded_plan9")
  colorscheme default
endif

" load local config
let g:vimrc_local = $HOME."/.vimrc.local"
if filereadable(g:vimrc_local)
  execute "source " . g:vimrc_local
endif
