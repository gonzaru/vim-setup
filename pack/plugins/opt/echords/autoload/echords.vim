vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_echords') || !get(g:, 'echords_enabled')
  finish
endif
g:autoloaded_echords = true

# some references:
# https://www.gnu.org/software/emacs/refcards/pdf/refcard.pdf

# enable echords keys
export def Enable()

  # TODO: check all C-S-* for terminal

  # TODO: the M-key works well with gui, but does not in terminal

  # TODO: terminal maps

  # TODO: vnoremap?

  # TODO: onoremap?

  # TODO: more maps
  # https://www.gnu.org/software/emacs/manual/html_node/emacs/Shift-Selection.html
  # when Shift modifier, it triggers a built-in feature called shift-select-mode

  # TODO: indent-region
  # C-M-\ # TODO: indent-region

  # go to functions
  # M-?  (xref-find-references)

  # TODO:
  # C-M-b move backward sexp
  # C-M-f move forward sexp
  # C-M-u
  # C-M-p
  # C-M-n

  # TODO: ispell-word
  # M-$

  # TODO: fill-paragraph
  # M-q

  # TODO: set-fill-column
  # C-x f

  # TODO: bookmarks
  # C-x r m              bookmark-set
  # C-x r b              bookmark-jump
  # C-x r SPC            point-to-register
  # C-x r j              jump-to-register

  # TODO: help commands
  # <C-h>i
  # <C-h>f
  # <C-h>v

  # TODO: evaluate expression
  # <C-x><C-e>
  # <M-:> # see the file

  # TODO: show all lines in the current buffer containing a match
  # <M-s>o

  # TODO: mark defun (put mark at end of this defun, point at beginning)
  # <C-H-h>

  # TODO: check all :help popupmenu-keys

  # go to line beginning
  # collission: i_CTRL-A insert previously inserted text
  # inoremap <C-a> <C-o>0
  # inoremap <C-a> <C-o>^
  inoremap <C-a> <Home>
  # go to line beginning + select
  if has('gui_running')
    inoremap <C-S-a> <C-o>v0
  else
    # <F13> is mapped to <C-S-a>
    inoremap <F13> <C-o>v0
  endif
  # use <C-x><C-a> to use the builtin <C-a>
  inoremap <C-x><C-a> <C-a>
  # collission: c_CTRL-A all names that match the pattern in front of the cursor are inserted (default: <C-b>)
  cnoremap <C-a> <Home>
  # use <C-x><C-a> to use the builtin <C-a>
  cnoremap <C-x><C-a> <C-a>

  # go to line end
  # collission: i_CTRL-E insert the character which is below the cursor
  # inoremap <C-e> <C-o>$
  # inoremap <expr> <C-e> pumvisible() ? "\<C-e>" : "\<C-o>$"
  # see complementum map with <C-e>
  # if !get(g:, 'complementum_enabled')
  #   inoremap <expr> <C-e> pumvisible() <bar><bar> preinserted() ? "\<C-e>" : "\<End>"
  # endif
  # inoremap <C-e> <End>
  inoremap <expr> <C-e> pumvisible() ? "\<C-e>" : "\<End>"

  # go to line end + select
  if has('gui_running')
    inoremap <C-S-e> <C-o>v$
  else
    # <F14> is mapped to <C-S-e>
    inoremap <F14> <C-o>v$
  endif
  # it goes by default
  # cnoremap <C-e <End>

  # mark set
  if has('gui_running')
    inoremap <C-Space> <C-o>v
  else
    inoremap <C-@> <C-o>v
  endif
  # collission: i_CTRL-@ insert previously inserted text and stop insert
  inoremap <C-S-@> <C-o>v

  # mark entire buffer
  inoremap <C-x>h <C-o>gg<C-o>VG

  # go to last edit position
  if has('gui_running')
    inoremap <C-u><C-Space> <C-o>g;
  else
    inoremap <C-u><C-@> <C-o>g;
  endif

  # exchange point and mark (implies vnoremap)
  vnoremap <C-x><C-x> o

  # go to line beginning (non-blank)
  inoremap <M-m> <C-o>^
  # go to line beginning (non-blank) + select
  inoremap <M-S-m> <C-o>v^

  # go to sentence backward
  inoremap <M-a> <C-o>(
  # go to sentence backward + select
  inoremap <M-S-a> <C-o>v(

  # go to sentence forward
  inoremap <M-e> <C-o>)
  # go to sentence forward + select
  inoremap <M-S-e> <C-o>v)

  # kill to start of sentence
  inoremap <C-x><BackSpace> <C-o>d(

  # kill to end of sentence
  inoremap <M-k> <C-o>d)

  # go to paragraph backward
  inoremap <M-{> <C-o>{
  inoremap <C-Up> <C-o>{
  # go to paragraph backward + select
  if has('gui_running')
    inoremap <C-S-Up> <C-o>v{
  else
    inoremap <F18> <C-o>v{
  endif

  # go to paragraph forward
  inoremap <M-}> <C-o>}
  inoremap <C-Down> <C-o>}
  # go to paragraph forwared + select
  if has('gui_running')
    inoremap <C-S-Down> <C-o>v}
  else
    inoremap <F19> <C-o>v}
  endif

  # TODO: recheck method up/down
  # method up
  inoremap <C-M-a> <C-o>[m
  inoremap <C-M-Home> <C-o>[m
  # method down
  inoremap <C-M-e> <C-o>]m
  inoremap <C-M-End> <C-o>]m

  # goto previous line
  # collission: i_CTRL-P completion find the previous match
  # TODO: is ignored with omni (C-x C-o)
  # inoremap <C-p> <Up>
  # inoremap <expr> <C-p> pumvisible() <bar><bar> preinserted() ? "\<C-p>" : "\<Up>"
  # inoremap <expr> <C-p> pumvisible() ? "\<C-e>\<Up>" : "\<Up>"
  inoremap <expr> <C-p> pumvisible() ? "\<C-p>" : "\<Up>"

  # goto previous line + select
  if has('gui_running')
    inoremap <C-S-p> <C-o>v0k
  else
    inoremap <F22> <C-o>v0k
  endif
  # select previous line
  vnoremap <C-p> k

  # goto next line
  # collission: i_CTRL-N completion find the next match
  # TODO: is ignored with omni (C-x C-o)
  # inoremap <C-n> <Down>
  # inoremap <expr> <C-n> pumvisible() <bar><bar> preinserted() ? "\<C-n>" : "\<Down>"
  # inoremap <C-n> <Down>
  # inoremap <expr> <C-n> pumvisible() ? "\<C-e>\<Down>" : "\<Down>"
  inoremap <expr> <C-n> pumvisible() ? "\<C-n>" : "\<Down>"
  # goto next line + select
  if has('gui_running')
    inoremap <C-S-n> <C-o>v$j
  else
    inoremap <F21> <C-o>v$j
  endif
  # select next line
  vnoremap <C-n> j

  # write
  # collission with i_CTRL_X_s and i_CTRL_X i_CTRL_X_s locate the word in front of the cursor and first the first spell suggestion for it
  # save-some-buffers, this saves all the buffers
  inoremap <C-x>s <Cmd>wall<CR>
  # save-buffer, this saves only the current buffer
  inoremap <C-x><C-s> <Cmd>update<CR>

  # go to directory
  inoremap <C-x>d <C-\><C-n><ScriptCmd>feedkeys(":edit " .. expand('%:p:~:h') .. $"{expand('%:p:h') == '/' ? '' : '/'}")<CR>

  # write file
  inoremap <C-x><C-w> <C-\><C-n><ScriptCmd>feedkeys(":write " .. expand('%:p:~:h') .. $"{expand('%:p:h') == '/' ? '' : '/'}")<CR>

  # transpose characters
  # collission: i_CTRL-T insert one shiftwidth of indent at the start of the current line
  # TODO: looks a little different
  # TODO: builtin <C-t> it's very useful
  inoremap <C-t> <C-o>x<C-o>p

  # transpose words
  inoremap <M-t> <C-o>dw<C-o>e<Right><Space><C-o>p<Left>

  # transpose lines
  # collission: i_CTRL-X i_CTRL-T like completion thesaurus dictionary
  inoremap <C-x><C-t> <C-o>dd<C-o>p

  # TODO: transpose sexps
  # inoremap <C-M-t>

  # character backward
  inoremap <C-b> <Left>
  # TODO: problem with plugin cmplwild (when popup menu)
  # collission: c_CTRL-B cursor to beginning of command-line <Home>
  cnoremap <C-b> <Left>

  # character forward
  # collission: i_CTRL-F characters that can precede each key
  inoremap <C-f> <Right>
  # collission: c_CTRL-F open the command-line window
  cnoremap <C-f> <Right>
  # use <C-x><C-f> to use the vim builtin <C-f>
  cnoremap <C-x><C-f> <C-f>

  # word backward
  # inoremap <M-b> <S-Left>
  inoremap <M-b> <C-o>b
  inoremap <M-Left> <C-o>b
  inoremap <C-Left> <C-o>b
  cnoremap <M-b> <S-Left>

  # word forward
  # inoremap <M-f> <S-Right>
  inoremap <M-f> <C-o>e<Right>
  inoremap <M-Right> <C-o>e<Right>
  inoremap <C-Right> <C-o>e<Right>
  cnoremap <M-f> <S-Right>

  # delete character backward
  # same as vim <DEL> = <BackSpace>
  # delete character forward
  # collission: i_CTRL_D delete one shiftwidth of indent at the start of the current line
  # inoremap <C-d> <C-o>x
  inoremap <C-d> <Del>
  # collission: c_CTRL-D list names that match the pattern in front of the cursor
  cnoremap <C-d> <Del>
  cnoremap <M-d> <S-Right><C-w>

  # delete word backward
  inoremap <M-BackSpace> <C-w>
  cnoremap <M-BackSpace> <C-w>
  inoremap <C-BackSpace> <C-w>
  cnoremap <C-BackSpace> <C-w>

  # delete the whole line
  # inoremap <C-S-BackSpace> <C-o>0<C-o>dd
  inoremap <C-S-BackSpace> <C-o>0<C-o>d$

  # TODO: check
  # delete word forward
  inoremap <M-d> <C-o>dw
  inoremap <C-Delete> <C-o>dw

  # delete line backward
  # default <C-u> already does it
  # TODO: map to <M-0> fails
  # inoremap <M-0><C-k> <C-u>
  # inoremap <M--><C-k> <C-u>

  # delete line forward
  # collission: i_CTRL_K enter digraph
  # inoremap <C-k> <C-o>d$
  inoremap <expr> <C-k> empty(trim(getline('.'))) ? "\<C-o>dd" : "\<C-o>d$"
  # collission: c_CTRL-K enter diagraph
  # cnoremap <C-k> <ScriptCmd>setcmdline("")<CR>
  cnoremap <C-k> <ScriptCmd>DeleteCmdLine()<CR>

  # yank
  # recheck alternative to == (formating)
  # collission: i_CTRL_Y insert the character which is above the cursor
  # inoremap <C-y> <C-o>p<C-o>==
  inoremap <expr> <C-y> pumvisible() <bar><bar> preinserted() ? "\<C-y>" : "\<C-o>p\<C-o>=="
  # collission: c_CTRL-Y when there is a modeless selection, copy the selection into the clipboard
  # cnoremap <C-y> <C-r>*
  # cnoremap <C-y> <C-r>+
  cnoremap <C-y> <C-r>"

  # paste interactive (yank-pop)
  inoremap <M-y> <C-x><C-r>

  # undo
  # inoremap <C-/> <C-o>u
  # inoremap <C-x>u <C-o>u
  # inoremap <C-S-_> <C-e>
  inoremap <C-/> <Cmd>undo<CR>
  inoremap <C-x>u <Cmd>undo<CR>
  inoremap <Undo> <Cmd>undo<CR>
  # collission: i_CTRL-_ switch between languages
  if has('gui_running')
   inoremap <C-S-_> <Cmd>undo<CR>
  else
   inoremap <F15> <Cmd>undo<CR>
  endif

  # redo (undo-redo)
  # inoremap <C-M-S-_> <C-o><C-r>
  if has('gui_running')
    inoremap <C-M-S-_> <Cmd>redo<CR>
  else
    inoremap <F17> <Cmd>redo<CR>
  endif
  if has('gui_running')
    inoremap <C-S-?> <Cmd>redo<CR>
  else
    inoremap <F16> <Cmd>redo<CR>
  endif

  # select another buffer
  # TODO: list etc
  # inoremap <C-x>b <C-o>:bprevious
  # inoremap <C-x>b <C-\><C-n>:b<Space>
  inoremap <C-x>b <C-\><C-n><ScriptCmd>feedkeys(":b " .. fnamemodify(bufname('#'), ":~"))<CR>

  # list all buffers
  inoremap <C-x><C-b> <Cmd>ls<CR>

  # delete a buffer
  inoremap <C-x>k <C-o>:bdelete<Space>

  # go to mini buffer M-x
  inoremap <M-x> <C-\><C-n>:
  inoremap <C-x><CR> <C-\><C-n>:
  # inoremap <M-:> <C-\><C-n>:

  # tags
  # find a tag (xref-find-definitions)
  inoremap <M-.> <C-o><C-]>
  # find a tag (a definition) in other window
  inoremap <C-x>4. <C-o><C-w>}
  # go back (xref-go-back)
  inoremap <M-,> <C-o><C-t>

  # shells / terminal
  inoremap <M-!> <C-o>:!

  # M-num numeric arguments (C-u num)
  inoremap <M-1> <C-o>1
  inoremap <M-2> <C-o>2
  inoremap <M-3> <C-o>3
  inoremap <M-4> <C-o>4
  inoremap <M-5> <C-o>5
  inoremap <M-6> <C-o>6
  inoremap <M-7> <C-o>7
  inoremap <M-8> <C-o>8
  inoremap <M-9> <C-o>9
  # C-num numeric arguments (C-u num)
  inoremap <C-1> <C-o>1
  inoremap <C-2> <C-o>2
  inoremap <C-3> <C-o>3
  inoremap <C-4> <C-o>4
  inoremap <C-5> <C-o>5
  inoremap <C-6> <C-o>6
  inoremap <C-7> <C-o>7
  inoremap <C-8> <C-o>8
  inoremap <C-9> <C-o>9

  # TODO: map to this? (undefined by default)
  ### inoremap <M-p> <Up>
  ### inoremap <M-n> <Down>
  cnoremap <M-p> <Up>
  cnoremap <M-n> <Down>

  # scroll down
  # collission: i_CTRL_V insert non-digit literally
  # inoremap <C-v> <C-o><C-d>
  inoremap <C-v> <PageDown>

  # scroll up
  # inoremap <M-v> <C-o><C-u>
  inoremap <M-v> <PageUp>

  # scroll current line top, center, bottom  (zz, zb, zt)
  # collission: i_CTRL_L when 'insertmode' is set, go to noremal mode
  # inoremap <C-l> <ScriptCmd>ScrollTo()<CR>
  inoremap <expr> <C-l> pumvisible() ? "\<C-l>" : "\<ScriptCmd>ScrollTo()\<CR>"

  # move between top, middle, bottom of window
  inoremap <M-r> <ScriptCmd>CursorTo()<CR>

  # TODO
  # scroll left, right

  # kill through next occurence of char (zap to char)
  inoremap <M-z> <ScriptCmd>ZapToChar()<CR>

  # uppercase word
  inoremap <M-u> <C-o>gUw

  # lowercase word
  inoremap <M-l> <C-o>guw

  # TODO: first non blank "_" or up/down "+" "-"
  # capitalize word
  inoremap <M-c> <C-o>~

  # set the buffer in read only (toggle)
  inoremap <C-x><C-q> <Cmd>setlocal ro!<CR>

  # goto line
  # TODO: add message "Goto line: "
  inoremap <M-g>g <C-o>:
  inoremap <M-g><M-g> <C-o>:

  # TODO: errors
  # go to next error
  # <M-g>n
  # go to previous error
  # <M-g>p

  # go to buffer beginning
  inoremap <M-<> <C-o>1G<C-o>0
  inoremap <C-Home> <C-o>1G<C-o>0

  # go to buffer end
  inoremap <M->>  <C-o>G<C-o>$
  inoremap <C-End>  <C-o>G<C-o>$

  # abbreviations (all buffers)
  # expand previous world
  # inoremap <M-/> <C-p>
  # TODO: check if <C-n> or <C-o>
  inoremap <expr> <M-/> pumvisible() <bar><bar> preinserted() ? "\<C-e>\<C-p>" : "\<C-p>"

  # abbreviations (current buffer)
  # expand previous world
  # inoremap <C-M-/> <C-x><C-p>
  # inoremap <expr> <C-M-/> pumvisible() ? "\<C-e>\<C-x>\<C-p>" : "\<C-x>\<C-p>"

  # windows

  # close this window
  inoremap <C-x>0 <C-o><C-w>c

  # delete all other windows (only)
  inoremap <C-x>1 <C-o><C-w>o

  # split window horizontal
  inoremap <C-x>2 <C-o><C-w>s

  # split window vertical
  inoremap <C-x>3 <C-o><C-w>v

  # switch cursor to another window
  inoremap <C-x>o <C-o><C-w>w

  # resize vertical equal window
  inoremap <C-x>+ <C-o><C-w>=

  # shrink window narrower
  inoremap <C-x>{ <C-o><C-w><

  # grow window wider
  inoremap <C-x>} <C-o><C-w>>

  # TODO: shrink window if larger than buffer
  # C-x -

  # TODO: recheck
  # grow window taller
  inoremap <C-x>^ <C-o><C-w>+

  # scroll other window forward
  # TODO: do it better
  inoremap <C-M-v> <C-o><C-w>w<C-o><PageDown><C-o><C-w>W

  # scroll other window forward
  if has('gui_running')
    inoremap <C-M-S-v> <C-o><C-w>w<C-o><PageUp><C-o><C-w>W
  else
    inoremap <F20> <C-o><C-w>w<C-o><PageUp><C-o><C-w>W
  endif

  # TODO: recheck
  # find file other window
  inoremap <C-x>4<C-f> <C-o>:split<Space>

  # TODO: recheck
  # formating
  # delete indentation
  # inoremap <M-^> <Up><End><C-o>J
  # TODO? add command?

  # TODO
  # folds

  # macros
  # recording 'z' as a tmp macro register
  inoremap <C-x>( <ScriptCmd>setreg('z', 'a')<CR><C-\><C-n>qZa
  inoremap <C-x>) <C-o>q
  # collision: i_CTRL-e insert the character which is below the cursor
  inoremap <C-x>e <C-\><C-n>@z

  #) abort)
  # collission: i_CTRL_G don't start a new undo block with the next left/right cursor movement
  # inoremap <C-g> <C-c>
  # inoremap <C-g> <C-\><C-n>
  inoremap <expr> <C-g> pumvisible() <bar><bar> preinserted() ? "\<C-e>" : "\<C-\>\<C-n>"
  # collission: c_CTRL-g when 'incsearch' is set, entering a search pattern for '/' or '?' move to the next match
  cnoremap <C-g> <C-c><Esc>
  # collission: v_CTRL-g (several options)
  vnoremap <C-g> <Esc>gV
  onoremap <C-g> <Esc>

  # TODO: add more
  # extras
  if g:echords_extra_mappings
    # begin a new line below the cursor
    inoremap <M-o> <C-o>o

    # begin a new line above the cursor
    inoremap <M-S-o> <C-o>O

    # duplicate line
    inoremap <leader>ed <C-o>^<C-o>yy<C-o>p

    # copy line
    inoremap <leader>ew <C-o>^<C-o>yy

    # copy from above
    inoremap <leader>eP <C-o>k<C-o>^<C-o>yy<C-o>p

    # join line
    inoremap <leader>eJ <C-o>J

    # prints the current file name and the cursor position
    inoremap <C-x>= <C-o><C-g>

    # count words
    inoremap <leader>e= <Cmd>echo wordcount()<CR>

    # zap up to char
    inoremap <leader>ez <ScriptCmd>ZapUpToChar()<CR>
  endif

  # TODO: recheck terminal maps to disable section
  # terminal

  # word backward
  tnoremap <M-b> <Esc>b

  # word forward
  tnoremap <M-f> <Esc>f

  # delete character backward
  tnoremap <C-d> <Del>

  # delete word forward
  tnoremap <M-d> <Esc>d

  # move
  tnoremap <M-p> <Up>
  tnoremap <M-n> <Down>

  # delete word backward
  tnoremap <M-BackSpace> <Esc>b<Esc>d
  tnoremap <C-BackSpace> <Esc>b<Esc>d

  # TODO: bash?
  tnoremap <C-M-h> <Esc>b<Esc>d

  # delete the whole line
  tnoremap <C-S-BackSpace> <C-a><C-k>
enddef

# disable echords keys
export def Disable()
  silent! iunmap <C-a>
  if has('gui_running')
    silent! iunmap <C-S-a>
  else
    silent! iunmap <F13>
  endif
  silent! iunmap <C-x><C-a>
  silent! cunmap <C-a>
  silent! cunmap <C-x><C-a>
  silent! iunmap <C-e>
  if has('gui_running')
    silent! iunmap <C-S-e>
  else
    silent! iunmap <F14>
  endif
  if has('gui_running')
    silent! iunmap <C-Space>
  else
    silent! iunmap <C-@>
  endif
  silent! iunmap <C-S-@>
  silent! iunmap <C-x>h
  if has('gui_running')
    silent! iunmap <C-u><C-Space>
  else
    silent! iunmap <C-u><C-@>
  endif
  silent! vunmap <C-x><C-x>
  silent! iunmap <M-m>
  silent! iunmap <M-S-m>
  silent! iunmap <M-a>
  silent! iunmap <M-S-a>
  silent! iunmap <M-e>
  silent! iunmap <M-S-e>
  silent! iunmap <C-x><BackSpace>
  silent! iunmap <M-k>
  silent! iunmap <M-{>
  silent! iunmap <C-Up>
  if has('gui_running')
    silent! iunmap <C-S-Up>
  else
    silent! iunmap <F18>
  endif
  silent! iunmap <M-}>
  silent! iunmap <C-Down>
  if has('gui_running')
    silent! iunmap <C-S-Down>
  else
    silent! iunmap <F19>
  endif
  silent! iunmap <C-M-a>
  silent! iunmap <C-M-Home>
  silent! iunmap <C-M-e>
  silent! iunmap <C-M-End>
  silent! iunmap <C-p>
  if has('gui_running')
    silent! iunmap <C-S-p>
  else
    silent! iunmap <F22>
  endif
  silent! vunmap <C-p>
  silent! iunmap <C-n>
  if has('gui_running')
    silent! iunmap <C-S-n>
  else
    silent! iunmap <F21>
  endif
  silent! vunmap <C-n>
  silent! iunmap <C-x>s
  silent! iunmap <C-x><C-s>
  silent! iunmap <C-x>d
  silent! iunmap <C-x><C-w>
  silent! iunmap <C-t>
  silent! iunmap <M-t>
  silent! iunmap <C-x><C-t>
  silent! iunmap <C-b>
  silent! cunmap <C-b>
  silent! iunmap <C-f>
  silent! cunmap <C-f>
  silent! cunmap <C-x><C-f>
  silent! iunmap <M-b>
  silent! iunmap <M-Left>
  silent! iunmap <C-Left>
  silent! cunmap <M-b>
  silent! iunmap <M-f>
  silent! iunmap <M-Right>
  silent! iunmap <C-Right>
  silent! cunmap <M-f>
  silent! iunmap <C-d>
  silent! cunmap <C-d>
  silent! cunmap <M-d>
  silent! iunmap <M-BackSpace>
  silent! cunmap <M-BackSpace>
  silent! iunmap <C-BackSpace>
  silent! cunmap <C-BackSpace>
  silent! iunmap <C-S-BackSpace>
  silent! iunmap <M-d>
  silent! iunmap <C-Delete>
  silent! iunmap <C-k>
  silent! cunmap <C-k>
  silent! iunmap <C-y>
  silent! cunmap <C-y>
  silent! iunmap <M-y>
  silent! iunmap <C-/>
  silent! iunmap <C-x>u
  silent! iunmap <Undo>
  if has('gui_running')
    silent! iunmap <C-S-_>
  else
    silent! iunmap <F15>
  endif
  if has('gui_running')
    silent! iunmap <C-M-S-_>
  else
    silent! iunmap <F17>
  endif
  if has('gui_running')
    silent! iunmap <C-S-?>
  else
    silent! iunmap <F16>
  endif
  silent! iunmap <C-x>b
  silent! iunmap <C-x><C-b>
  silent! iunmap <C-x>k
  silent! iunmap <M-x>
  silent! iunmap <C-x><CR>
  # inoremap <M-:> <M-:>
  silent! iunmap <M-.>
  silent! iunmap <C-x>4.
  silent! iunmap <M-,>
  silent! iunmap <M-!>
  silent! iunmap <M-1>
  silent! iunmap <M-2>
  silent! iunmap <M-3>
  silent! iunmap <M-4>
  silent! iunmap <M-5>
  silent! iunmap <M-6>
  silent! iunmap <M-7>
  silent! iunmap <M-8>
  silent! iunmap <M-9>
  silent! iunmap <C-1>
  silent! iunmap <C-2>
  silent! iunmap <C-3>
  silent! iunmap <C-4>
  silent! iunmap <C-5>
  silent! iunmap <C-6>
  silent! iunmap <C-7>
  silent! iunmap <C-8>
  silent! iunmap <C-9>
  ### silent! iunmap <M-p>
  ### silent! iunmap <M-n>
  silent! cunmap <M-p>
  silent! cunmap <M-n>
  silent! iunmap <C-v>
  silent! iunmap <M-v>
  silent! iunmap <C-l>
  silent! iunmap <M-r>
  silent! iunmap <M-z>
  silent! iunmap <M-u>
  silent! iunmap <M-l>
  silent! iunmap <M-c>
  silent! iunmap <C-x><C-q>
  silent! iunmap <M-g>g
  silent! iunmap <M-g><M-g>
  silent! iunmap <M-<>
  silent! iunmap <C-Home>
  silent! iunmap <M->>
  silent! iunmap <C-End>
  silent! iunmap <M-/>
  silent! iunmap <C-M-/>
  silent! iunmap <C-x>0
  silent! iunmap <C-x>1
  silent! iunmap <C-x>2
  silent! iunmap <C-x>3
  silent! iunmap <C-x>o
  silent! iunmap <C-x>+
  silent! iunmap <C-x>{
  silent! iunmap <C-x>}
  silent! iunmap <C-x>^
  silent! iunmap <C-M-v>
  if has('gui_running')
    silent! iunmap <C-M-S-v>
  else
    silent! iunmap <F20>
  endif
  silent! iunmap <C-x>4<C-f>
  silent! iunmap <C-x>(
  silent! iunmap <C-x>)
  silent! iunmap <C-x>e
  # inoremap <M-^> <M-^>
  silent! iunmap <C-g>
  silent! cunmap <C-g>
  silent! vunmap <C-g>
  silent! ounmap <C-g>

  if g:echords_extra_mappings
    silent! iunmap <M-o>
    silent! iunmap <M-S-o>
    silent! iunmap <leader>ed
    silent! iunmap <leader>ew
    silent! iunmap <leader>eP
    silent! iunmap <leader>eJ
    silent! iunmap <C-x>=
    silent! iunmap <leader>e=
    silent! iunmap <leader>ez
  endif

  # TODO: recheck terminal maps to disable section
  # terminal
  silent! tunmap <M-b>
  silent! tunmap <M-f>
  silent! tunmap <C-d>
  silent! tunmap <M-d>
  silent! tunmap <M-p>
  silent! tunmap <M-n>
  silent! tunmap <M-BackSpace>
  silent! tunmap <C-BackSpace>
  silent! tunmap <C-S-BackSpace>
  # TODO: bash?
  silent! tunmap <C-M-h>
enddef

# toggle echords keys
export def Toggle()
  if g:echords_enabled
    Disable()
  else
    Enable()
  endif
  g:echords_enabled = !g:echords_enabled
  v:statusmsg = $"echords={g:echords_enabled}"
enddef

# zap to char
def ZapToChar()
  echo "Zap to char: "
  var char = getcharstr()
  if !empty(char)
    execute $"normal! df{char}"
  endif
enddef

# zap up to char
def ZapUpToChar()
  echo "Zap up to char: "
  var char = getcharstr()
  if !empty(char)
    execute $"normal! dt{char}"
  endif
enddef

# scroll current line to top, center, bottom  (zz, zb, zt)
var scrlkey: string = ""
def ScrollTo()
  if scrlkey == "" || scrlkey == "zb"
    normal! zt
    scrlkey = "zt"
  elseif scrlkey == "zt"
    normal! zz
    scrlkey = "zz"
  elseif scrlkey == "zz"
    normal! zb
    scrlkey = "zb"
  endif
enddef

# cursor line to top, center, bottom  (H, M, L)
var crskey: string = ""
def CursorTo()
  if crskey == "" || crskey == "L"
    normal! H
    crskey = "H"
  elseif crskey == "H"
    normal! M
    crskey = "M"
  elseif crskey == "M"
    normal! L
    crskey = "L"
  endif
enddef

# delete cmd line <C-k>
def DeleteCmdLine(): void
  var pos = getcmdpos()
  if pos <= 1
    setcmdline("")
    setcmdpos(1)
    return
  endif
  var line = getcmdline()
  var new = line[: pos - 2]
  setcmdline(new)
  setcmdpos(strlen(new) + 1)
  # TODO: custom collission with <C-Space> (see vimrc.local)
enddef
